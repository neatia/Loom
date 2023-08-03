#if os(iOS)

import SwiftUI
import UIKit

extension GraniteScrollView {

    struct Reader : UIViewRepresentable {
        
        @Binding var startDraggingOffset : CGPoint
        let onReachedEdge : ReachedEdgeHandler?

        @State var isLoaded : Bool = false
        
        func makeUIView(context: Context) -> some UIView {
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
                
                scrollView.delegate = context.coordinator
            }
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(startDraggingOffset: $startDraggingOffset,
                        onReachedEdge: onReachedEdge)
        }
        
    }
    
}

extension GraniteScrollView {
    
    class Coordinator : NSObject, UIScrollViewDelegate {
        
        @Binding var startDraggingOffset : CGPoint
        
        let onReachedEdge : ReachedEdgeHandler?
        
        fileprivate var hasAlreadyReachedBottom: Bool = false
        fileprivate var hasAlreadyReachedTop: Bool = true
        
        public init(startDraggingOffset : Binding<CGPoint>,
                    onReachedEdge : ReachedEdgeHandler?) {
            self._startDraggingOffset = startDraggingOffset
            self.onReachedEdge = onReachedEdge
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            startDraggingOffset = scrollView.contentOffset
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if (scrollView.contentSize.height - scrollView.contentOffset.y) <= scrollView.frame.size.height
            {
                if !hasAlreadyReachedBottom
                {
                    hasAlreadyReachedBottom = true
                    onReachedEdge?(.bottom)
                }
            }
            else
            {
                hasAlreadyReachedBottom = false
            }
            
            if scrollView.contentOffset.y <= 0
            {
                if !hasAlreadyReachedTop
                {
                    hasAlreadyReachedTop = true
                    onReachedEdge?(.top)
                }
            }
            else
            {
                hasAlreadyReachedTop = false
            }
        }
        
    }
    
}

#endif
