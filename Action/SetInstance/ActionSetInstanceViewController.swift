//
//  ActionViewController.swift
//  Action
//
//  Created by Ritesh Pakala on 9/4/23.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

public struct Const {
    public struct General {
        public static let appURL: String = "nycLoom://"
        public static let groupName: String = "group.nyc.loom"
    }
}

class ActionSetInstanceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let item = self.extensionContext?.inputItems[0] as? NSExtensionItem {
            //let providers = item.attachments?.compactMap { $0 as? NSItemProvider }
            
            guard let urlProvider = item.attachments?.first(where: { $0.hasItemConformingToTypeIdentifier("public.url") }) else {
                return
            }
            
            urlProvider.loadItem(forTypeIdentifier: "public.url",
                                 options: nil,
                                 completionHandler: { (item, error) in
                
                if let url = item as? URL{
                    
                    let userDefault = UserDefaults(suiteName: Const.General.groupName)
                    if userDefault != nil {
                        userDefault?.setValue(url.absoluteString, forKey: "instanceURL")
                        userDefault?.synchronize()
                        let _ = self.openURL(URL(string: Const.General.appURL+"setInstance")!)
                    }
                }
                
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            })
        }
    }

    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }

}
