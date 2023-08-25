//
//  Write.Import.swift
//  Loom (iOS)
//
//  Created by PEXAVC on 7/21/23.
//

import Foundation
import SwiftUI
import Granite
#if os(macOS)
import AppKit

extension Write {
    func importPicture() {
        if let data = state.imageData,
           let image = NSImage(data: data) {
            ModalService.shared.present(GraniteAlertView(title: "MISC_MODIFY") {
                GraniteAlertAction {
                    PhotoView(image: image)
                        .frame(minWidth: Device.isMacOS ? 400 : nil, minHeight: Device.isMacOS ? 400 : nil)
                }
                
                GraniteAlertAction(title: "MISC_REPLACE") {
                    _importPicture()
                }
                GraniteAlertAction(title: "MISC_REMOVE", kind: .destructive) {
                    _state.imageData.wrappedValue = nil
                }
                GraniteAlertAction(title: "MISC_CANCEL")
            }
            )
        } else {
            _importPicture()
        }
    }
    func _importPicture() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowedContentTypes = [.image]
        if panel.runModal() == .OK {
            if let url = panel.url {
                if let data = try? Data(contentsOf: url),
                   //TODO: customize compression level
                   let image = NSImage(data: data)?.compress() {
                    _state.imageData.wrappedValue = image.pngData()
                }
            }
        }
    }
}

#else
import PhotosUI
extension Write {
    func importPicture() {
        modal.presentSheet(id: Write.modalId,
                           detents: [.large]) {
            ImagePicker(imageData: _state.imageData)
                .attach( {
                    modal.dismissSheet(id: Write.modalId)
                }, at: \.dismiss)
        }
    }
}
//TODO: move
struct ImagePicker: UIViewControllerRepresentable, GraniteActionable {
    @GraniteAction<Void> var dismiss
    @Binding var imageData: Data?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController,
                    didFinishPicking results: [PHPickerResult]) {
            
            guard let provider = results.first?.itemProvider else {
                picker.dismiss(animated: true)
                return
            }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async { [weak self] in
                        self?.parent.imageData = (image as? UIImage)?.compress().png
                        
                        self?.parent.dismiss.perform()
                    }
                }
            } else {
                picker.dismiss(animated: true)
            }
        }
    }
}

import UIKit
import ImageIO

struct ImageHeaderData{
    static var PNG: [UInt8] = [0x89]
    static var JPEG: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47]
    static var TIFF_01: [UInt8] = [0x49]
    static var TIFF_02: [UInt8] = [0x4D]
}

enum ImageFormat{
    case Unknown, PNG, JPEG, GIF, TIFF
}


extension NSData {
    var imageFormat: ImageFormat {
        var buffer = [UInt8](repeating: 0, count: 1)
        self.getBytes(&buffer, range: NSRange(location: 0,length: 1))
        if buffer == ImageHeaderData.PNG
        {
            return .PNG
        } else if buffer == ImageHeaderData.JPEG
        {
            return .JPEG
        } else if buffer == ImageHeaderData.GIF
        {
            return .GIF
        } else if buffer == ImageHeaderData.TIFF_01 || buffer == ImageHeaderData.TIFF_02{
            return .TIFF
        } else{
            return .Unknown
        }
    }
}
#endif
