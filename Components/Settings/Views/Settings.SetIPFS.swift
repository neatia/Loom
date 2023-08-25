//
//  Settings.SetIPFS.swift
//  Loom
//
//  Created by PEXAVC on 8/2/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import IPFSKit

extension Settings {
    func setIPFSProperties() {
        var gateway: String = config.state.ipfsGatewayUrl
        var apiEndpoint: String = ""
        var key: String = ""
        var secret: String = ""
        var bindingGateway = Binding<String>.init(get: {
            return gateway
        }, set: { newValue in
            gateway = newValue
        })
        
        var bindingKey = Binding<String>.init(get: {
            return key
        }, set: { newValue in
            key = newValue
        })
        
        var bindingSecret = Binding<String>.init(get: {
            return secret
        }, set: { newValue in
            secret = newValue
        })
        
        ModalService.shared.presentSheet {
            GraniteStandardModalView(title: "Set IPFS Properties", maxHeight: 360) {
                VStack(spacing: 0) {
                    TextField("MISC_GATEWAY", text: bindingGateway)
                        .textFieldStyle(.plain)
                        .frame(height: 60)
                        .padding(.horizontal, .layer4)
                        .font(.title3.bold())
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color.alternateBackground.opacity(0.3))
                        )
                        .padding(.bottom, .layer3)
                    
                    //Only infura for now
//                    TextField("API Endpoint", text: bindingGateway)
//                        .textFieldStyle(.plain)
//                        .frame(height: 40)
//                        .padding(.horizontal, .layer4)
//                        .font(.title3.bold())
//                        .background(
//                            RoundedRectangle(cornerRadius: 8)
//                                .foregroundColor(Color.alternateBackground.opacity(0.3))
//                        )
//                        .frame(minWidth: Device.isMacOS ? 400 : nil)
                    
                    TextField("FORM_API_KEY", text: bindingKey)
                        .textFieldStyle(.plain)
                        .frame(height: 60)
                        .padding(.horizontal, .layer4)
                        .font(.title3.bold())
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color.alternateBackground.opacity(0.3))
                        )
                        .padding(.bottom, .layer3)
                    
                    TextField("FORM_API_SECRET", text: bindingSecret)
                        .textFieldStyle(.plain)
                        .frame(height: 60)
                        .padding(.horizontal, .layer4)
                        .font(.title3.bold())
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color.alternateBackground.opacity(0.3))
                        )
                        .padding(.bottom, .layer4)
                    
                    HStack(spacing: .layer2) {
                        Spacer()
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            ModalService.shared.dismissSheet()
                        } label: {
                            Text("MISC_CANCEL")
                                .font(.headline)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, .layer2)
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            key = ""
                            secret = ""
                            
                            //TODO: reuse
                            do {
                                try AccountService.deleteToken(identifier: AccountService.keychainIPFSKeyToken, service: AccountService.keychainService)
                                
                                try AccountService.deleteToken(identifier: AccountService.keychainIPFSSecretToken, service: AccountService.keychainService)
                                
                                LoomLog("inserted ipfs data into keychain", level: .debug)
                                
                                config._state.ipfsGatewayUrl.wrappedValue = gateway
                                config._state.isIPFSAvailable.wrappedValue = true
                            } catch let error {
                                
                                LoomLog("keychain: \(error)", level: .error)
                            }
                            
                            config._state.isIPFSAvailable.wrappedValue = false
                            ModalService.shared.dismissSheet()
                        } label: {
                            Text("MISC_REMOVE")
                                .font(.headline)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, .layer2)
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            
                            guard let secretData = secret.data(using: .utf8),
                                  let keyData = key.data(using: .utf8) else {
                                return
                            }
                            
                            do {
                                try AccountService.insertToken(keyData, identifier: AccountService.keychainIPFSKeyToken, service: AccountService.keychainService)
                                
                                try AccountService.insertToken(secretData, identifier: AccountService.keychainIPFSSecretToken, service: AccountService.keychainService)
                                
                                LoomLog("inserted ipfs data into keychain", level: .debug)
                                
                                IPFSKit.gateway = InfuraGateway(key, secret: secret, gateway: gateway)
                                
                                config._state.ipfsGatewayUrl.wrappedValue = gateway
                                config._state.isIPFSAvailable.wrappedValue = true
                            } catch let error {
                                LoomLog("keychain: \(error)", level: .error)
                            }
                            
                            
                            ModalService.shared.dismissSheet()
                        } label: {
                            Text("MISC_DONE")
                                .font(.headline)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                    .padding(.top, .layer4)
                }
            }
        }
    }
}
