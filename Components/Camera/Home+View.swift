import Granite
import GraniteUI
import UIKit

import SwiftUI
import Foundation

extension Home: View {
    public var view: some View {
        ZStack {
            CameraView(content: state.content)
            
            VStack(spacing: 0) {
                if state.status.isEmpty == false {
                    photoPreview
                } else {
                    Spacer()
                }
                
                HStack(spacing: 0) {
                    Spacer().frame(width: 4)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Image(systemName: "gearshape")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .font(.system(size: 24, weight: .bold))
                            Spacer()
                            
                            if state.status.contains(.captured) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                    .font(.system(size: 22, weight: .bold))
                                    .onTapGesture(center.snapCancel)
                            } else {
                                Image(systemName: "circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .font(.system(size: 24, weight: .bold))
                                    .onTapGesture(center.snap)
                            }
                            
                            Spacer()
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 27, height: 27)
                                .font(.system(size: 24, weight: .bold))
                            Spacer()
                        }
                        Spacer().frame(height: 16)
                    }
                    .frame(height: 75)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.75).blur(radius: 24))
                    .cornerRadius(48,
                                  corners: [.bottomLeft,
                                            .bottomRight])
                    .cornerRadius(8,
                                  corners: [.topLeft,
                                            .topRight])
                    Spacer().frame(width: 4)
                }
                
                Spacer().frame(height: state.hasAppeared ? 4 : 64)
                
            }
            .animation(.default, value: state.hasAppeared)
            
            if state.status.isEmpty == false {
                Color.white
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: 0, y: state.captureWallHeight)
                    .animation(.default, value: state.captureWallHeight)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .padding(.top, 16)
        .animation(.default)
        .addGraniteSheet(modalService.sheetManager, background: Color.black)
    }
}

extension Home {
    var photoPreview: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 4)
            
            HStack {
                Spacer().frame(width: 4)
                VStack(alignment: .center) {
                    Spacer()
                    if let image = state.capturedPhoto {
                        HStack(alignment: .center) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(8.0)
                                .frame(width: UIScreen.main.bounds.width * 0.8)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.75).blur(radius: 24))
                .cornerRadius(8, corners: .allCorners)
                Spacer().frame(width: 4)
            }
            
            Spacer().frame(height: 4)
            
            photoPreviewControls
            
            
            Spacer().frame(height: 4)
        }
    }
    
    var photoPreviewControls: some View {
        HStack {
            Spacer().frame(width: 4)
            VStack(alignment: .center) {
                Spacer()
                
                HStack(alignment: .center) {
                    
                    Spacer()
                    
                    Image(systemName: "signature")
                        .resizable()
                        .frame(width: 33, height: 27)
                        .font(.system(size: 27, weight: .bold))
                        .onTapGesture(center.snap)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.circle")
                        .resizable()
                        .frame(width: 27, height: 27)
                        .font(.system(size: 27, weight: .bold))
                        .onTapGesture(center.snap)
                    
                    Spacer()
                    
                    
                }
                
                
                Spacer()
            }
            .frame(height: 75)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.75).blur(radius: 24))
            .cornerRadius(8, corners: .allCorners)
            
            Spacer().frame(width: 4)
        }
    }
}
