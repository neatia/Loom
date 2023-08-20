//
//  FrameChangePlacer.swift
//  Placement
//
//  Created by Sam Pettersson on 2022-10-03.
//

import Foundation
import SwiftUI

class FrameChangePlacerView<L: PlacementLayout>: UIView {
    var coordinator: Coordinator<L>
    var children: _VariadicView.Children
    
    init(coordinator: Coordinator<L>, children: _VariadicView.Children) {
        self.coordinator = coordinator
        self.children = children
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var containedInViewController: UIViewController? = nil
    
    override func didMoveToSuperview() {
        containedInViewController = self.superview?.parentViewController
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        if let viewController = containedInViewController
             ?? self.superview?.parentViewController,
           let globalFrame = self.superview?.convert(
                self.frame,
                to: viewController.view
           )
        {
            coordinator.globalFrame = globalFrame
        }
                        
        coordinator.placeSubviews()
    }
}

extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}

struct FrameChangePlacer<L: PlacementLayout>: UIViewRepresentable {
    @EnvironmentObject var coordinator: Coordinator<L>
    var children: _VariadicView.Children
    var intrinsicSizes: [AnyHashable: CGSize]
    @Binding var keyboardFrame: CGRect
    
    func makeUIView(context: Context) -> FrameChangePlacerView<L> {
        FrameChangePlacerView(coordinator: coordinator, children: children)
    }
    
    func updateUIView(_ uiView: FrameChangePlacerView<L>, context: Context) {
    }
    
    func _overrideSizeThatFits(
        _ size: inout CoreGraphics.CGSize,
        in proposedSize: SwiftUI._ProposedSize,
        uiView: FrameChangePlacerView<L>
    ) {
        // force SwiftUI to recalculate sizeThatFits
        let _ = keyboardFrame
        
        size = proposedSize.placementProposedViewSize.replacingUnspecifiedDimensions(
            by: .zero
        )
        
        uiView.setNeedsLayout()
    }
}
