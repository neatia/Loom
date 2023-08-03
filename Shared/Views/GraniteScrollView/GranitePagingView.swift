#if os(iOS)

import Foundation
import SwiftUI

public struct GranitePagingView<Content : View> : View {
    
    fileprivate struct Reader : UIViewRepresentable {
        
        class Coordinator : NSObject, UIScrollViewDelegate {
            
            weak var scrollView : UIScrollView? {
                
                didSet {
                    guard let scrollView = scrollView else {
                        return
                    }
                    
                    scrollView.delegate = self
                    scrollView.contentOffset.y = scrollView.frame.height * CGFloat(initialPageIndex)
                }
                
            }
            
            var initialPageIndex : Int = 0
            @Binding var currentPageIndex : Int
            
            init(currentPageIndex : Binding<Int>) {
                self._currentPageIndex = currentPageIndex
            }
            
            func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
                currentPageIndex = Int(floor(scrollView.contentOffset.y / scrollView.frame.height))
            }
            
        }
        
        @Binding var currentPageIndex : Int
        @State var isLoaded : Bool = false
        
        func makeUIView(context: Context) -> some UIView {
            context.coordinator.initialPageIndex = currentPageIndex
            
            let view = UIView()
            view.alpha = 0.0
            return view
        }
        
        func updateUIView(_ uiView: UIViewType, context: Context) {
            DispatchQueue.main.async {
                guard isLoaded == false else {
                    return
                }
                
                guard let scrollView = uiView.ancestor(ofType: UIScrollView.self) else {
                    return
                }
                
                isLoaded = true
                
                context.coordinator.scrollView = scrollView
                scrollView.isPagingEnabled = true
            }
        }
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(currentPageIndex: $currentPageIndex)
        }
        
    }
    
    private let axes : Axis.Set
    private let showsIndicators : Bool
    private let content : Content
    
    @Binding var currentPageIndex : Int
    
    public init(_ axes : Axis.Set = .vertical,
                showsIndicators: Bool = false,
                currentPageIndex : Binding<Int>,
                @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self._currentPageIndex = currentPageIndex
        self.content = content()
    }
    
    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content
                .overlay(
                    Reader(currentPageIndex: $currentPageIndex).allowsHitTesting(false)
                )
        }
    }
    
}

#endif
