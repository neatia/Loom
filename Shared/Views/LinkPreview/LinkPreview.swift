import SwiftUI
import LinkPresentation
import Granite
/**
Gets and sets to this dictionary-like type are atomic.

Does not fully implement correct value semantics for copy
operations, since the contained queue is a reference type
and will be shared among copies of this object

*/
struct AtomicDictionary<KeyType:Hashable,ValueType>
{
  private var internalDictionary:Dictionary<KeyType,ValueType> = [:]
    private let queue = DispatchQueue.init(label: "atomic.dict")
  
  /* provide subscript accessors */
  subscript(key: KeyType) -> ValueType? {
    get {
      var value : ValueType?
        self.queue.sync() { () -> Void in
        value = self.internalDictionary[key]
      }
      return value
    }
    
    set {
        setValue(value: newValue, forKey: key)
    }
  }
  
  mutating func setValue(value: ValueType?, forKey key: KeyType) {
    // use a dispatch barrier so writes are serialized
      
      queue.sync(flags: .barrier) {
          self.internalDictionary[key] = value
          
      }
  }
}

class LinkPreviewCache {
    static let shared: LinkPreviewCache = .init()
    var operationQueue: OperationQueue = .init()
    var imageOperationQueue: OperationQueue = .init()
    var iconOperationQueue: OperationQueue = .init()
    init() {
        operationQueue.underlyingQueue = .main//global(qos: .background)
        operationQueue.maxConcurrentOperationCount = 1
        
        imageOperationQueue.underlyingQueue = .main//global(qos: .background)
        imageOperationQueue.maxConcurrentOperationCount = 1
        
        iconOperationQueue.underlyingQueue = .main
        iconOperationQueue.maxConcurrentOperationCount = 1
    }
    
    var canFetchImage: Bool = true
    var canFetch: Bool = true
    var cache: Bool = true
    var cacheKeys: [String] = []
    var metadataCache: [String: LPLinkMetadata?] = [:]
    var imageCache: [String: GraniteImage] = [:]
    
    var iconCache: [String: GraniteImage] = [:]
    var sizeCache: [String: CGSize] = [:]
    
    let limit: Int = 120
    let flushSize: Int = 12 //page size?
    var isFlushing: Bool = false
    
    func flush() {
        guard isFlushing == false else { return }
        isFlushing = true
        operationQueue.addOperation { [weak self] in
            guard let self else { return }
            if self.cacheKeys.count >= self.limit {
                var keys: [String] = Array(self.cacheKeys.prefix(self.flushSize))
                self.cacheKeys.removeFirst(self.flushSize)
                for key in keys {
                    self.metadataCache[key] = nil
                    self.imageCache[key] = nil
                    self.iconCache[key] = nil
                    self.sizeCache[key] = nil
                }
                self.isFlushing = false
                print("[LinkPreviewCache] flushed: \(self.flushSize)")
            }
        }
    }
}

public struct LinkPreview: View {
    let url: URL?
    
    var cacheKey: String {
        (
            url?.absoluteString ?? UUID().uuidString
        ) + "\(type)"
    }
    
    var cachedMetadata: LPLinkMetadata? {
        if let data = LinkPreviewCache.shared.metadataCache[cacheKey] {
            return data
        } else {
            return metaData
        }
    }
    
    @State private var isPresented: Bool = false
    @State private var metaData: LPLinkMetadata? = nil
    
    #if os(iOS)
    var backgroundColor: Color = Color(.systemGray5)
    #else
    var backgroundColor: Color = Color.black.opacity(0.5)
    #endif
    
    var primaryFontColor: Color = .foreground
    var secondaryFontColor: Color = .secondaryForeground
    var titleLineLimit: Int = 3
    var type: LinkPreviewType = .auto
    
    public init(url: URL?) {
        self.url = url
        
    }
    
    public var body: some View {
        if let url {
            if let metaData = cachedMetadata {
                Button(action: {
                    #if os(iOS)
                        if UIApplication.shared.canOpenURL(url) {
                            self.isPresented.toggle()
                        }
                    #else
                    self.isPresented.toggle()
                    #endif
                }, label: {
                    LinkPreviewDesign(metaData: metaData, type: type, backgroundColor: backgroundColor, primaryFontColor: primaryFontColor, secondaryFontColor: secondaryFontColor, titleLineLimit: titleLineLimit)
                })
                    .buttonStyle(LinkButton())
                    .universalWebCover(isPresented: $isPresented, url: url)
                    .animation(.spring(), value: metaData)
            }
            else {
                HStack {
                    HStack(spacing: 10){
                        #if os(iOS)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: secondaryFontColor))
                        #else
                        ProgressView()
                            .scaleEffect(0.6)
                            .progressViewStyle(CircularProgressViewStyle(tint: secondaryFontColor))
                        #endif
                        
                        Text(url.host ?? "")
                            .font(.caption)
                            .foregroundColor(primaryFontColor)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .foregroundColor(backgroundColor)
                    )
                    .onTapGesture {
                        #if os(iOS)
                        if UIApplication.shared.canOpenURL(url) {
                            self.isPresented.toggle()
                        }
                        #else
                        self.isPresented.toggle()
                        #endif
                    }
                    
                    Spacer()
                }
                .onAppear {
                    guard cachedMetadata == nil else {
                        return
                    }
                    _ = Task {
                        let provider = LPMetadataProvider()
                        let metadata = try? await provider.startFetchingMetadata(for: url)
                        
                        if LinkPreviewCache.shared.cache {
                            LinkPreviewCache.shared.cacheKeys.append(cacheKey)
                            LinkPreviewCache.shared.metadataCache[cacheKey] = metadata
                        }
                        
                        self.metaData = metadata
                    }
                }
//                .onAppear {
//                    if cachedMetadata == nil {
//                        getMetaData(url: url)
//                    }
//                }
                .universalWebCover(isPresented: $isPresented, url: url)
                
            }
        }
    }
    
    func getMetaData(url: URL) {
//        LinkPreviewCache.shared.operationQueue.addOperation {
////            while !LinkPreviewCache.shared.canFetch {}
////            LinkPreviewCache.shared.canFetch = false
//            DispatchQueue.main.async {
//                let provider = LPMetadataProvider()
//                provider.startFetchingMetadata(for: url) { meta, err in
//                    LinkPreviewCache.shared.canFetch = true
//                    guard let meta = meta else {return}
//                    if LinkPreviewCache.shared.cache {
//                        LinkPreviewCache.shared.cacheKeys.append(cacheKey)
//                        LinkPreviewCache.shared.metadataCache[cacheKey] = meta
//                        LinkPreviewCache.shared.flush()
//                    }
//                    //withAnimation(.spring()) {
//                    self.metaData = meta
//                    //}
//                }
//            }
//        }
        DispatchQueue.main.async {
            let provider = LPMetadataProvider()
            provider.startFetchingMetadata(for: url) { meta, err in
                LinkPreviewCache.shared.canFetch = true
                guard let meta = meta else {return}
                if LinkPreviewCache.shared.cache {
                    LinkPreviewCache.shared.cacheKeys.append(cacheKey)
                    LinkPreviewCache.shared.metadataCache[cacheKey] = meta
                    LinkPreviewCache.shared.flush()
                }
                //withAnimation(.spring()) {
                self.metaData = meta
                //}
            }
        }
    }
}

