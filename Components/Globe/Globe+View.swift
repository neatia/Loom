import Granite
import GraniteUI
import SwiftUI
import LemmyKit

extension Globe: View {
    public var view: some View {
        VStack(spacing: 0) {
            mainView
            
        }
//        .addGraniteSheet(modal.sheetManager,
//                         modalManager: modal.modalSheetManager,
//                         background: Color.clear)
//        .addGraniteModal(modal.modalManager)
        .background(Color.background)
    }
}
