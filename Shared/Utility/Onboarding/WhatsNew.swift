//
//  WhatsNewView.swift
//  Loom
//
//  Created by PEXAVC on 8/27/23.
//

import Foundation

//What's New Modal
//        .onAppear {
//            if content.state.lastVersionUpdateNotice != Device.appVersion {
//                modal.presentSheet {
//                    Group {
//                        if let url = URL(string: "https://gateway.ipfs.io/ipfs/Qme8cLrjpATAixqtqkvJAvimyj1JVurAUSURayzFiiTYpf") {
//
//                            PostContentView(url,
//                                            fullPage: Device.isMacOS)
//                                .frame(width: Device.isMacOS ? 600 : nil,
//                                       height: Device.isMacOS ? 500 : nil)
//                                .onAppear {
//
//                                    content._state.lastVersionUpdateNotice.wrappedValue = Device.appVersion ?? ""
//                                }
//                        } else {
//                            EmptyView()
//                        }
//                    }
//                }
//
//                LoomLog("\(Device.appVersion ?? "unknown app version")", level: .debug)
//
//            }
//        }
