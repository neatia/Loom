#if os(iOS)
import Foundation
import SwiftUI

struct CameraView : UIViewRepresentable {
    typealias UIViewType = CameraContentView
    
    unowned let content : CameraContent
    
    init(content : CameraContent) {
        self.content = content
    }
    
    func makeUIView(context: Context) -> CameraContentView {
        CameraContentView(content: content)
    }
    
    func updateUIView(_ uiView: CameraContentView, context: Context) {
        //No contents here
    }
    
}
#endif
