//
//  LinkPreviewDesign.swift
//  
//
//  Created by 이웅재 on 2021/12/08.
//

import SwiftUI
import LinkPresentation
import Granite
import UniformTypeIdentifiers
import ModerationKit

/*
 TODO: cleanup and remove LinkPreview and related files in favor of
       ContentMetadataView
 */

struct LinkPreviewDesign: View {
    
    let metaData: LPLinkMetadata
    let type: LinkPreviewType
    
    var cacheKey: String {
        (
            metaData.url?.absoluteString ?? UUID().uuidString
        ) + "\(type)"
    }
    
    var cachedImage: GraniteImage? {
        //TODO: memory access issue
        if let data = LinkPreviewCache.shared.imageCache[cacheKey] {
            return data
        } else {
            return image
        }
    }
    
    var cachedIcon: GraniteImage? {
        if let data = LinkPreviewCache.shared.iconCache[cacheKey] {
            return data
        } else {
            return icon
        }
    }
    
    var cachedHeight: CGFloat? {
        if let data = LinkPreviewCache.shared.sizeCache[cacheKey] {
            return data.height
        } else {
            return nil
        }
    }
    
    @State private var image: GraniteImage? = nil
    @State private var icon: GraniteImage? = nil
    @State private var isPresented: Bool = false
    @State private var containerSize: CGSize? = nil
    
    private let backgroundColor: Color
    private let primaryFontColor: Color
    private let secondaryFontColor: Color
    private let titleLineLimit: Int
    
    init(metaData: LPLinkMetadata, type: LinkPreviewType = .auto, backgroundColor: Color, primaryFontColor: Color, secondaryFontColor: Color, titleLineLimit: Int) {
        self.metaData = metaData
        self.type = type
        self.backgroundColor = backgroundColor
        self.primaryFontColor = primaryFontColor
        self.secondaryFontColor = secondaryFontColor
        self.titleLineLimit = titleLineLimit
    }
    
    var body: some View {
        Group{
            switch type {
            case .small:
                smallType
            case .large, .largeNoMetadata:
                largeType
            case .auto:
                largeType
            }
        }
        .onAppear {
            guard cachedImage == nil else {
                return
            }
            _ = Task {
                containerSize = LinkPreviewCache.shared.sizeCache[cacheKey]
                let type = String(describing: UTType.image)
                guard let imageProvider = metaData.imageProvider else {
                    return
                }
                if imageProvider.hasItemConformingToTypeIdentifier(type) {
                    var thumb: GraniteImage? = nil
                    guard let item = try? await imageProvider.loadItem(forTypeIdentifier: type) else {
                        return
                    }
                    
                    if thumb == nil,
                       item is GraniteImage {
                        thumb = item as? GraniteImage
                    }
                    
                    if thumb == nil,
                       item is URL {
                        guard let url = item as? URL,
                              let data = try? Data(contentsOf: url) else { return }
                        
                        thumb = GraniteImage(data: data)
                    }
                    
                    if thumb == nil,
                       item is Data {
                        guard let data = item as? Data else { return }
                        
                        thumb = GraniteImage(data: data)
                    }
                    
                    if let thumb,
                       PagerFilter.enableForNSFWExtended {
                        let isNSFW = await ModerationKit.current.check(thumb, for: .nsfw)
                        
                        if !isNSFW {
                            self.image = thumb
                            
                            if LinkPreviewCache.shared.cache {
                                LinkPreviewCache.shared.imageCache[cacheKey] = thumb
                            }
                        }
                    } else {
                        self.image = thumb
                        
                        if LinkPreviewCache.shared.cache {
                            LinkPreviewCache.shared.imageCache[cacheKey] = thumb
                        }
                    }
                }
            }
            
        }
    }
    
    @ViewBuilder
    var smallType: some View {
        HStack {
            HStack(spacing: 8){
                VStack(alignment: .leading, spacing: 0){
                    if let title = metaData.title {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(primaryFontColor)
                            .lineLimit(titleLineLimit)
                    }
                    
                    if let url = metaData.url?.host {
                        Text("\(url)")
                            .foregroundColor(secondaryFontColor)
                            .font(.footnote)
                    }
                }
                
                if let img = image {
#if os(iOS)
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 32, height: 32, alignment: .center)
                        .clipped()
                        .cornerRadius(4)
#else
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 32, height: 32, alignment: .center)
                        .clipped()
                        .cornerRadius(4)
#endif
                }
                else {
                    Image(systemName: "arrow.up.forward.app.fill")
                        .resizable()
                        .foregroundColor(secondaryFontColor)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24, alignment: .center)
                }
                
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Rectangle()
                    .foregroundColor(backgroundColor)
            )
            .cornerRadius(12)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var largeType: some View {
        VStack(alignment: .leading, spacing: 0){
            if let img = cachedImage {
                ZStack(alignment: .bottomTrailing){
                    
                    if LinkPreviewCache.shared.cache,
                       cachedHeight == nil {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    LinkPreviewCache.shared.sizeCache[cacheKey] = proxy.size
                                    containerSize = proxy.size
                                }
                        }
                    }
                        
#if os(iOS)
                    if let containerSize {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: containerSize.height)
                            .clipped()
                            .scrollOnOverflow()
                        
                        if let icon = cachedIcon {
                            Image(uiImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32, alignment: .center)
                                .cornerRadius(6)
                                .padding(.all, 8)
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        }
                        
                        if let icon = cachedIcon {
                            Image(uiImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32, alignment: .center)
                                .cornerRadius(6)
                                .padding(.all, 8)
                        }
                    }
                    
#else
                    if let containerSize {
                        Image(nsImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: containerSize.height)
                            .clipped()
                            .scrollOnOverflow()
                        
                        if let icon = cachedIcon {
                            Image(nsImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32, alignment: .center)
                                .cornerRadius(6)
                                .padding(.all, 8)
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            Image(nsImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        }
                        
                        if let icon = cachedIcon {
                            Image(nsImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32, alignment: .center)
                                .cornerRadius(6)
                                .padding(.all, 8)
                        }
                    }
#endif
                }
                .frame(height: cachedHeight)
            }
            
            if type != .largeNoMetadata {
                HStack {
                    HStack(spacing: 8){
                        VStack(alignment: .leading, spacing: 0){
                            if let title = metaData.title {
                                Text(title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(primaryFontColor)
                                    .lineLimit(titleLineLimit)
                                    .padding(.bottom, image == nil ? 0 : 4)
                            }
                            
                            if let url = metaData.url?.host {
                                Text("\(url)")
                                    .foregroundColor(secondaryFontColor)
                                    .font(.footnote)
                            }
                        }
                        
                        if cachedImage != nil {
                            Spacer()
                        }
                        else {
                            Image(systemName: "arrow.up.forward.app.fill")
                                .resizable()
                                .foregroundColor(secondaryFontColor)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24, alignment: .center)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if cachedImage == nil {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(backgroundColor)
                            } else {
                                Rectangle()
                                    .foregroundColor(backgroundColor)
                            }
                        }
                    )
                    if cachedImage == nil {
                        Spacer()
                    }
                }
            }
        }
        .cornerRadius(12)
    }
    
//    func getImage(){
//        guard image == nil,
//              let metadataURL = metaData.url else {
//            return
//        }
//
//        let IMAGE_TYPE = kUTTypeImage as String
//
////        LinkPreviewCache.shared.imageOperationQueue.addOperation {
////            while !LinkPreviewCache.shared.canFetchImage {}
////            LinkPreviewCache.shared.canFetchImage = false
//
//            DispatchQueue.main.async {
//                metaData.imageProvider?.loadFileRepresentation(forTypeIdentifier: IMAGE_TYPE, completionHandler: { (url, imageProviderError) in
////                    LinkPreviewCache.shared.canFetchImage = true
//                    if imageProviderError != nil {
//
//                    }
//                    guard let url else { return }
//                    let data = url.path
//
//                    let image = GraniteImage(contentsOfFile: (data))
//                    self.image = image
//
//                    if LinkPreviewCache.shared.cache {
//                        LinkPreviewCache.shared.imageCache[cacheKey] = image
//                    }
//                })
//            }
////        }
//    }
//    func getIcon(){
//        guard let metadataURL = metaData.url else {
//            return
//        }
//
//        let IMAGE_TYPE = kUTTypeImage as String
//
//        LinkPreviewCache.shared.iconOperationQueue.addOperation {
//            metaData.iconProvider?.loadFileRepresentation(forTypeIdentifier: IMAGE_TYPE, completionHandler: { (url, imageProviderError) in
//                if imageProviderError != nil {
//
//                }
//                guard let url else { return }
//                let data = url.path
//
//                self.icon = GraniteImage(contentsOfFile: (data))
//
//                if LinkPreviewCache.shared.cache {
//                    LinkPreviewCache.shared.iconCache[cacheKey] = image
//                }
//            })
//        }
//    }
}


public enum LinkPreviewType {
    case small
    case large
    case auto
    case largeNoMetadata
}
