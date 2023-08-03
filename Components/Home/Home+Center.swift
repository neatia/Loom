//
//  HomeState.swift
//  PEX
//
//  Created by PEXAVC on 7/18/22.
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
            var currentTabIndex: Int = 0
        }
        
        @Store public var state: Center.State
    }
}

