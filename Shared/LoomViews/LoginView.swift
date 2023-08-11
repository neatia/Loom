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
import LemmyKit

struct LoginView: View {
    @GraniteAction<Void> var cancel
    @GraniteAction<Void> var add
    
    var addToProfiles: Bool = false
    
    @State var username: String = ""
    @State var password: String = ""
    @State var token2FA: String = ""
    @State var captcha: String = ""
    @State var captchaResponse: CaptchaResponse? = nil
    @State var host: String = ""
    
    @Relay var account: AccountService
    
    enum Kind {
        case login
        case signup
    }
    
    @State var kind: Kind = .login
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                #if os(iOS)
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color.background)
                    .edgesIgnoringSafeArea(.all)
                #endif
                
                if addToProfiles {
                    addToProfilesForm
                } else {
                    loginForm
                }
            }
            .frame(maxHeight: 400)
        }
        .frame(width: Device.isMacOS ? 300 : nil, height: Device.isMacOS ? 400 : nil)
    }
}

extension LoginView {
    var addToProfilesForm: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer4) {
                VStack {
                    Spacer()
                    Text("MISC_ADD")
                        .font(.title.bold()) + Text(" ") + Text("TITLE_ACCOUNT")
                        .font(.title.bold())
                }
                
                Spacer()
            }
            .frame(height: 36)
            .padding(.bottom, .layer4)
            
            Divider()
                .padding(.bottom, .layer4)
            
            TextField("LOGIN_FORM_USERNAME", text: $username)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .textContentType(.username)
                .frame(height: 60)
                .padding(.horizontal, .layer4)
                .font(.title3.bold())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer2)
            
            SecureField("LOGIN_FORM_PASSWORD", text: $password)
            //TextField("Enter your password", text: $password)
                .textFieldStyle(.plain)
                .frame(height: 60)
                .padding(.horizontal, .layer4)
                .font(.title3.bold())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer2)
                .textContentType(.password)
            
            TextField("https://lemmy.world", text: $host)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .frame(height: 60)
                .padding(.horizontal, .layer4)
                .font(.title3.bold())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer4)
        
            TextField("LOGIN_FORM_ONE_TIME_CODE", text: $token2FA)
                .textFieldStyle(.plain)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(height: 60)
                .padding(.horizontal, .layer4)
                .font(.title3.bold())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer4)
            
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
            
            Spacer()
        }
        .padding(.layer5)
    }
    //TODO: combing both/reuse
    var loginForm: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer4) {
                VStack {
                    Spacer()
                    switch kind {
                    case .login:
                        Text("AUTH_LOGIN")
                            .font(.title.bold())
                    case .signup:
                        Text("AUTH_SIGNUP")
                            .font(.title.bold())
                        
                    }
                }
                
                Spacer()
            }
            .frame(height: 36)
            .padding(.bottom, .layer4)
            
            Divider()
                .padding(.bottom, .layer4)
            
            TextField("LOGIN_FORM_USERNAME", text: $username)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .frame(height: 60)
                .padding(.horizontal, .layer4)
                .font(.title3.bold())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer2)
            
            SecureField("LOGIN_FORM_PASSWORD", text: $password)
                .textFieldStyle(.plain)
                .frame(height: 60)
                .padding(.horizontal, .layer4)
                .font(.title3.bold())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.tertiaryBackground)
                )
                .padding(.bottom, .layer4)
            
            if kind == .login {
                TextField("LOGIN_FORM_ONE_TIME_CODE", text: $token2FA)
                    .textFieldStyle(.plain)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .frame(height: 60)
                    .padding(.horizontal, .layer4)
                    .font(.title3.bold())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.tertiaryBackground)
                    )
                    .padding(.bottom, .layer4)
            } else {
                HStack {
                    if let captchaResponse,
                       let imageData = Data(base64Encoded: captchaResponse.png, options: .ignoreUnknownCharacters),
                       let image = GraniteImage(data: imageData) {
                        
                        PhotoView(image: image)
                            .clipped()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color.tertiaryBackground)
                            )
                            .padding(.trailing, .layer2)
                    } else {
                        ProgressView()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color.tertiaryBackground)
                            )
                            .padding(.trailing, .layer2)
                    }
                    
                    TextField("", text: $captcha)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .frame(height: 60)
                        .padding(.horizontal, .layer4)
                        .font(.title3.bold())
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color.tertiaryBackground)
                        )
                }
                .frame(height: 60)
                .padding(.bottom, .layer4)
                .task {
                    guard captchaResponse == nil else { return }
                    let captcha = await Lemmy.captcha()
                    captchaResponse = captcha?.ok
                }
            }
                
            
            #if os(macOS)
            Spacer()
            #endif
            
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
                                                        self.captchaResponse?.uuid,
                                                        self.captcha.isEmpty ? nil : self.captcha),
                                      addToProfiles: self.addToProfiles))
                    }
                } label: {
                    Text("AUTH_SIGNUP")
                        .font(.headline)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, Device.isMacOS ? 0 : .layer3)
            
            #if os(iOS)
            Spacer()
            #endif
        }
        .padding(.layer5)
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
