import Foundation
import SwiftUI
import Granite

public struct GraniteAlertView : GraniteModal {
    @GraniteAction<Void> var dismiss
    
    @EnvironmentObject private var manager : GraniteModalManager
    @Environment(\.graniteAlertViewStyle) private var style
    
    public let title : LocalizedStringKey?
    public let message : LocalizedStringKey?
    public let titleFont : Font?
    public let messageFont : Font?
    public let mode : GraniteAlertViewPresentationMode
    public let actions : [GraniteAlertAction]
    
    public init(title : LocalizedStringKey? = nil,
                message : LocalizedStringKey? = nil,
                titleFont : Font? = nil,
                messageFont : Font? = nil,
                mode : GraniteAlertViewPresentationMode = .alert,
                @GraniteAlertActionBuilder actions : () -> [GraniteAlertAction]) {
        self.title = title
        self.message = message
        self.titleFont = titleFont
        self.messageFont = messageFont
        self.mode = mode
        self.actions = actions()
    }
    
    public var backgroundBody: some View {
        style.overlayColor
            .transition(.opacity.animation(.easeOut(duration: 0.2)))
    }
    
    public var body: some View {
        if mode == .alert {
            alertBody
                .frame(maxWidth: Device.isMacOS ? 360 : nil)
        }
        else {
            sheetBody
        }
    }
    
    fileprivate var alertBody : some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            VStack(spacing: 0) {
                
                if let title = title {
                    Text(title)
                        .font(self.titleFont ?? .headline)
                        .padding(.top, style.alertVerticalPadding)
                    
                    Spacer()
                        .frame(height: 10)
                }
                
                if let message = message {
                    Text(message)
                        .padding(.vertical, style.alertVerticalPadding)
                        .padding(.horizontal, style.alertHorizontalPadding)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Divider()
                
                HStack(spacing: 0) {
                    ForEach(actions) { action in
                        if action.disableInteraction {
                            action.content
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        } else {
                            Button(action: {
                                manager.dismiss()
                                dismiss.perform()
                                action.handler()
                            }) {
                                action.content
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(action.kind == .destructive ? style.destructiveColor : style.actionColor)
                        }
                        
                        if action != actions.last {
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 48)
            }
            .foregroundColor(style.foregroundColor)
            .background(
                Group {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(style.backgroundColor)
                        .shadow(color: Color.black.opacity(0.05), radius: 10)
                }
            )
            .overlay(
                Group {
                    #if os(iOS)
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(UIColor.separator).opacity(0.5))
                    #else
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separatorColor).opacity(0.5))
                    #endif
                }
            )
            .padding(.horizontal, style.alertOuterHorizontalPadding)
            
            Spacer()
        }
        .transition(
            AnyTransition.opacity
                .combined(with: AnyTransition.scale(scale: 0.91))
                .combined(with: AnyTransition.offset(x: 0, y: -20))
        )
    }
    
    fileprivate var sheetBody : some View {
        ZStack(alignment: .bottom) {
            
            style.overlayColor.opacity(0.00001)
                .edgesIgnoringSafeArea(.all)
                .contentShape(Rectangle())
                .onTapGesture {
                    #if os(iOS)
                    manager.dismiss()
                    #endif
                }

            VStack(spacing: 0) {
                if let title = title {
                    Text(title)
                        .font(titleFont ?? .system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(style.foregroundColor.opacity(0.7))
                        .padding(.vertical, style.sheetVerticalSpacing)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    Divider()
                }
                
            
                if let message = message {
                    Spacer()
                    Text(message)
                        .frame(maxHeight: 120)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, style.sheetVerticalSpacing)
                    Spacer()
                    Divider()
                }
                
                ForEach(actions) { action in
                    if action.disableInteraction {
                        action.content
                            .frame(maxWidth: .infinity, alignment: .center)
                            .contentShape(Rectangle())
                            .padding(.vertical, style.sheetVerticalSpacing)
                    } else {
                        Button(action: {
                            manager.dismiss()
                            dismiss.perform()
                            action.handler()
                        }) {
                            action.content
                                .frame(maxWidth: .infinity, alignment: .center)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(action.kind == .destructive ? style.destructiveColor : style.actionColor)
                        .padding(.vertical, style.sheetVerticalSpacing)
                    }
                    
                    if action != actions.last {
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    #if os(iOS)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(style.backgroundColor)
                    #else
                    EmptyView()
                    #endif
                }
            )
            .padding(.horizontal, style.sheetHorizontalPadding)
            .padding(.vertical, style.sheetVerticalPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.move(edge: .bottom).animation(.easeOut(duration: 0.18)))
    }
    
}

struct GraniteAlertView_Previews: PreviewProvider {
    
    static var alert : some View {
        GraniteAlertView(title: "Delete Post",
                         message: "Are you sure you want to delete this post? This action cannot be undone.") {
            GraniteAlertAction(title: "Cancel")
            GraniteAlertAction(title: "Delete", kind: .destructive)
        }
        .graniteAlertViewStyle(
            GraniteAlertViewStyle(backgroundColor: Color.black,
                                  foregroundColor: Color.white,
                                  actionColor: Color.blue)
        )
    }
    
    static var previews: some View {
        Group {
            alert
                .preferredColorScheme(.dark)
            
            alert
        }
        .background(Color.white.opacity(0.2))
    }
}
