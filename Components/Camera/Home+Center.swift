//
//  HomeState.swift
//  PEX
//
//  Created by Ritesh on 7/18/22.
//  Copyright (c) 2022 Stoic Collective, LLC.. All rights reserved.
//
import Granite
import GraniteUI
import SwiftUI
import Combine

extension Home {
    struct Center: GraniteCenter {
        enum CaptureStatus: AnyStatus {
            case capturing
            case captured
        }
        
        struct State: GraniteState {
            static func == (lhs: Home.Center.State, rhs: Home.Center.State) -> Bool {
                lhs.hasAppeared == rhs.hasAppeared &&
                lhs.status == rhs.status
            }
            
            enum CodingKeys: CodingKey {
                case hasAppeared
            }
            
            var content: CameraContent = .init()
            var status: StatusSet<CaptureStatus> = .init()
            var capturedPhoto: UIImage? = nil
            
            var hasAppeared: Bool = false
            
            var captureWallHeight: CGFloat {
                status.contains(.captured) ? UIScreen.main.bounds.height : 0
            }
        }
        
        @Store public var state: Center.State
        
        @Event(.onAppear) var didAppear: DidAppear.Reducer
        @Event var snap: Snap.Reducer
        @Event var snapCancel: SnapCancel.Reducer
        @Event var photoTaken: PhotoTaken.Reducer
        
        init() {
            state.content = .init(reducer: photoTaken)
        }
    }
    
}

