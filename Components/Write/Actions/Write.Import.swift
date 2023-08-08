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
            modal.present(GraniteAlertView(title: "MISC_MODIFY") {
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
                
                if let data = try? Data(contentsOf: url) {
                    _state.imageData.wrappedValue = data
                }
            }
        }
    }
}

#else
import PhotosUI
extension Write {
    func importPicture() {
        modal.presentSheet {
            ImagePicker(imageData: _state.imageData)
                .attach( {
                    modal.dismissSheet()
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

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

            guard let provider = results.first?.itemProvider else {
                self.parent.dismiss.perform()
                picker.dismiss(animated: false)
                return
            }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async { [weak self] in
                        self?.parent.imageData = (image as? UIImage)?.png
                        self?.parent.dismiss.perform()
                        picker.dismiss(animated: false)
                    }
                }
            } else {
                
                self.parent.dismiss.perform()
                picker.dismiss(animated: false)
            }
        }
    }
}
#endif
