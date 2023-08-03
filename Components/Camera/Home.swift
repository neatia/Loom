//
//  HomeComponent.swift
//  PEX
//
//  Created by Ritesh on 7/18/22.
//  Copyright (c) 2022 Stoic Collective, LLC.. All rights reserved.
//
import Granite
import SwiftUI
import Combine

struct Home: GraniteComponent {
    @Command var center: Center
    @Relay public var modalService: ModalService
    
}

