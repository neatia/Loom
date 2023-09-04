//
//  LoginView.swift
//  Loom
//
//  Created by PEXAVC on 7/19/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import FederationKit

struct LoginView: View {
    @GraniteAction<Void> var cancel
    @GraniteAction<Void> var add
    
    var addToProfiles: Bool = false
    
    @State var username: String = ""
    @State var password: String = ""
    @State var token2FA: String = ""
    @State var captcha: String = ""
    //@State var captchaResponse: CaptchaResponse? = nil
    @State var host: String = ""
    
    @Relay var account: AccountService
    
    @State var isWorking: Bool = false
    
    enum Kind {
        case login
        case signup
    }
    
    @State var kind: Kind = .login
    
    var maxHeight: CGFloat {
        if Device.isMacOS {
            return (addToProfiles ? 480 : 400)
        } else if Device.isiPad {
            return (addToProfiles ? 480 : 400)
        } else {
            return 600
        }
    }
    
    var body: some View {
        
        GraniteStandardModalView(maxHeight: maxHeight) {
            if addToProfiles {
                HStack {
                    Text("MISC_ADD")
                        .font(.title.bold()) + Text("  ") + Text("TITLE_ACCOUNT")
                        .font(.title.bold())
                    
                    Spacer()
                }
            } else {
                HStack {
                    switch kind {
                    case .login:
                        Text("AUTH_LOGIN")
                            .font(.title.bold()) + Text("   @") + Text(FederationKit.host)
                            .font(.subheadline)
                    case .signup:
                        Text("AUTH_SIGNUP")
                            .font(.title.bold())
                    }
                    Spacer()
                }
            }
        } content: {
            if addToProfiles {
                addToProfilesForm
            } else {
                loginForm
            }
        }
    }
}

extension LoginView {
    var addToProfilesForm: some View {
        VStack(spacing: 0) {
            TextField("LOGIN_FORM_USERNAME", text: $username)
                .textFieldStyle(.plain)
                .correctionDisabled()
                .textContentType(.username)
                .frame(height: 60)
                .padding(.horizontal, .layer4)
                .font(.title3.bold())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer3)
            
            SecureField("LOGIN_FORM_PASSWORD", text: $password)
                .textFieldStyle(.plain)
                .textContentType(.password)
                .frame(height: 60)
                .padding(.horizontal, .layer4)
                .font(.title3.bold())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer3)
            
            #if os(iOS)
            TextToolView(text: $host,
                         kind: .link,
                         inheritStyle: .standard("MISC_URL"))
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer3)
            #else
            TextField("MISC_URL", text: $host)
                .textFieldStyle(.plain)
                .correctionDisabled()
                .frame(height: 60)
                .padding(.horizontal, .layer4)
                .font(.title3.bold())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer3)
            #endif
        
            #if os(iOS)
            TextToolView(text: $token2FA,
                         kind: .otp,
                         inheritStyle: .standard("LOGIN_FORM_ONE_TIME_CODE"))
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer5)
            #else
            TextField("LOGIN_FORM_ONE_TIME_CODE", text: $token2FA)
                .textFieldStyle(.plain)
                .otpContent()
                .frame(height: 60)
                .padding(.horizontal, .layer4)
                .font(.title3.bold())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer5)
            #endif
            
            HStack(spacing: .layer2) {
                Spacer()
                
                Button {
                    GraniteHaptic.light.invoke()
                    cancel.perform()
                } label: {
                    Text("MISC_CANCEL")
                        .font(.headline)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, .layer2)
                
                Button {
                    GraniteHaptic.light.invoke()
                    account
                        .center
                        .addProfile
                        .send(AccountService
                            .AddProfile
                            .Meta(username: username, password: password, token2FA: token2FA, host: host))
                } label: {
                    Text("MISC_ADD")
                        .font(.headline)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, .layer2)
        }
    }
    
    //TODO: combing both/reuse
    var loginForm: some View {
        VStack(spacing: 0) {
            
            TextField("LOGIN_FORM_USERNAME", text: $username)
                .textFieldStyle(.plain)
                .correctionDisabled()
                .frame(height: 60)
                .padding(.horizontal, .layer4)
                .font(.title3.bold())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer3)
            
            SecureField("LOGIN_FORM_PASSWORD", text: $password)
                .textFieldStyle(.plain)
                .frame(height: 60)
                .padding(.horizontal, .layer4)
                .font(.title3.bold())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer3)
            
            if kind == .login {
                #if os(iOS)
                TextToolView(text: $token2FA,
                             kind: .otp,
                             inheritStyle: .standard("LOGIN_FORM_ONE_TIME_CODE"))
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.tertiaryBackground)
                    )
                    .padding(.bottom, .layer5)
                #else
                TextField("LOGIN_FORM_ONE_TIME_CODE", text: $token2FA)
                    .textFieldStyle(.plain)
                    .otpContent()
                    .frame(height: 60)
                    .padding(.horizontal, .layer4)
                    .font(.title3.bold())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.tertiaryBackground)
                    )
                    .padding(.bottom, .layer5)
                #endif
            } else {
//                HStack {
//                    if let captchaResponse,
//                       let imageData = Data(base64Encoded: captchaResponse.png, options: .ignoreUnknownCharacters),
//                       let image = GraniteImage(data: imageData) {
//
//                        PhotoView(image: image)
//                            .clipped()
//                            .cornerRadius(8)
//                            .background(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .foregroundColor(Color.tertiaryBackground)
//                            )
//                            .padding(.trailing, .layer2)
//                    } else {
//                        #if os(macOS)
//                        ProgressView()
//                            .scaleEffect(0.6)
//                            .background(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .foregroundColor(Color.tertiaryBackground)
//                            )
//                            .padding(.trailing, .layer2)
//                        #else
//                        ProgressView()
//                            .background(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .foregroundColor(Color.tertiaryBackground)
//                            )
//                            .padding(.trailing, .layer2)
//                        #endif
//                    }
//
//                    TextField("", text: $captcha)
//                        .textFieldStyle(.plain)
//                        .correctionDisabled()
//                        .frame(height: 60)
//                        .padding(.horizontal, .layer4)
//                        .font(.title3.bold())
//                        .background(
//                            RoundedRectangle(cornerRadius: 8)
//                                .foregroundColor(Color.tertiaryBackground)
//                        )
//                }
//                .frame(height: 60)
//                .padding(.bottom, .layer4)
//                .task {
//                    guard captchaResponse == nil else { return }
//                    let captcha = await Lemmy.captcha()
//                    captchaResponse = captcha?.ok
//                }
                EmptyView()
            }
            
            HStack(spacing: .layer2) {
                Spacer()
                
                Button {
                    GraniteHaptic.light.invoke()
                    switch kind {
                    case .signup:
                        kind = .login
                    case .login:
                        account
                            .center
                            .auth
                            .send(AccountService
                                .Auth
                                .Meta(intent: .login(self.username,
                                                     self.password,
                                                     self.token2FA.isEmpty ? nil : self.token2FA),
                                      addToProfiles: self.addToProfiles))
                    }
                } label: {
                    Text("AUTH_LOGIN")
                        .font(.headline)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, .layer2)
                
                /*
                Button {
                    GraniteHaptic.light.invoke()
                    switch kind {
                    case .login:
                        kind = .signup
                    case .signup:
                        account
                            .center
                            .auth
                            .send(AccountService
                                .Auth
                                .Meta(intent: .register(self.username,
                                                        self.password,
                                                        nil,//self.captchaResponse?.uuid,
                                                        self.captcha.isEmpty ? nil : self.captcha),
                                      addToProfiles: self.addToProfiles))
                    }
                } label: {
                    Text("AUTH_SIGNUP")
                        .font(.headline)
                }
                .buttonStyle(PlainButtonStyle())
                 */
                
                Spacer()
            }
        }
    }
}

struct WhiteBorder: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.layer3)
    }
}

#if os(macOS)
extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
#endif
