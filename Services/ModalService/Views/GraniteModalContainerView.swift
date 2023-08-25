import Foundation
import SwiftUI
import Granite

public struct GraniteModalContainerView : View {
    @EnvironmentObject var manager : GraniteModalManager
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            
            ForEach(manager.presenters.indices, id: \.self) { index in
                manager.presenters[index].backgroundView
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(Double(index))
                    .onTapGesture {
                        manager.dismiss()
                    }
                
                manager.presenters[index].modalView
                    .zIndex(100.0 + Double(index))
                    .environmentObject(manager)
                    .frame(maxWidth: Device.isExpandedLayout ? ContainerConfig.iPhoneScreenWidth : nil)
            }
        }
    }
}
