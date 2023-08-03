#if os(iOS)
import Foundation
import AVFoundation
import UIKit
import Combine
import Granite

class CameraContentView : UIView {
    
    var contentGravity : CALayerContentsGravity {
        
        get {
            previewLayer.contentsGravity
        }
        
        set {
            previewLayer.contentsGravity = newValue
            
            switch previewLayer.contentsGravity {
            
            case .resizeAspectFill:
                previewLayer.videoGravity = .resizeAspectFill
                
            case .resizeAspect:
                previewLayer.videoGravity = .resizeAspect
                
            case .resize:
                previewLayer.videoGravity = .resize
                
            default:
                break
                
            }
            
        }
        
    }
    
    override var frame: CGRect {
        
        didSet {
            guard frame != .zero else {
                return
            }
            
            configureStream()
        }
        
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override static var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    fileprivate unowned let content : CameraContent
    
    fileprivate var session : AVCaptureSession? = nil
    fileprivate let fileOutput = AVCaptureMovieFileOutput()
    fileprivate let metadataOutput = AVCaptureMetadataOutput()
    fileprivate let photoOutput = AVCapturePhotoOutput()

    fileprivate var position : AVCaptureDevice.Position = .back
    
    fileprivate var cancellables = Set<AnyCancellable>()

    fileprivate var userInfo = [String : Any]()
    fileprivate var isCancelled : Bool = false
    
    fileprivate let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                          AVMetadataObject.ObjectType.code39,
                                          AVMetadataObject.ObjectType.code39Mod43,
                                          AVMetadataObject.ObjectType.code93,
                                          AVMetadataObject.ObjectType.code128,
                                          AVMetadataObject.ObjectType.ean8,
                                          AVMetadataObject.ObjectType.ean13,
                                          AVMetadataObject.ObjectType.aztec,
                                          AVMetadataObject.ObjectType.pdf417,
                                          AVMetadataObject.ObjectType.qr]
    
    fileprivate var hasScannedMetadataObjects = false
    
    init(content : CameraContent) {
        self.content = content
        
        super.init(frame: .zero)
        self.backgroundColor = .black
        self.contentGravity = .resizeAspectFill
        
        content.takePhotoPublisher.sink { [weak self] in
            guard let this = self else { return }
            let settings = AVCapturePhotoSettings()
            if let type = settings.availablePreviewPhotoPixelFormatTypes.first {
                settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: type]
                self?.photoOutput.capturePhoto(with: settings,
                                               delegate: this)
            }
        }.store(in: &cancellables)
        
        content.startRecordingPublisher.sink { [weak self] properties in
            print("[Recording] Starting")
            
            try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try? AVAudioSession.sharedInstance().setActive(true)
            
            guard let capturedSelf = self else {
                return
            }
            
            guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                print("[Recording] Error: cannot start recording")
                return
            }
            
            capturedSelf.isCancelled = false
            capturedSelf.userInfo = properties.userInfo
                
            if let duration = properties.duration {
                capturedSelf.fileOutput.maxRecordedDuration = duration
            }
            
            capturedSelf.fileOutput.movieFragmentInterval = .invalid
            
            if let connection = capturedSelf.fileOutput.connection(with: .video) {
                capturedSelf.fileOutput.setOutputSettings([
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoCompressionPropertiesKey: [
                        AVVideoAverageBitRateKey: 3500000.0
                    ]
                ], for: connection)
            }
            
            guard capturedSelf.fileOutput.connections.count > 0 else {
                return
            }
            
            capturedSelf.fileOutput.startRecording(to: url.appendingPathComponent(UUID().uuidString + ".mp4"),
                                                recordingDelegate: capturedSelf)
        }.store(in: &cancellables)
        
        content.stopRecordingPublisher.sink { [weak self] in
            self?.fileOutput.stopRecording()
        }.store(in: &cancellables)
        
        content.cancelRecordingPublisher.sink { [weak self] in
            self?.isCancelled = true
            self?.fileOutput.stopRecording()
        }.store(in: &cancellables)
        
        content.setCameraPositionPublisher.sink { [weak self] position in
            self?.position = position
            self?.configureStream()
        }.store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
        
        cancellables.removeAll()
    }
    
}

extension CameraContentView {
    
    override func didMoveToSuperview() {
        
    }
    
    fileprivate func configureStream() {
        session = session ?? AVCaptureSession()
        
        guard let session = session else {
            print("[Recording] Error: cannot start recording session")
            return
        }
        
        if session.isRunning == true {
            session.stopRunning()
            session.inputs.forEach { session.removeInput($0) }
            session.outputs.forEach { session.removeOutput($0) }
        }
        
        session.beginConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            print("[Recording] Error: cannot find video recording device")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice), session.canAddInput(videoInput) else {
            print("[Recording] Error: cannot configure video recording device")
            return
        }
        
        session.connections.first?.preferredVideoStabilizationMode = .cinematic
        
        session.addInput(videoInput)
        
        if content.options.kind == .video {
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
                print("[Recording] Error: cannot find audio recording device")
                return
            }
            
            guard let audioInput = try? AVCaptureDeviceInput(device: audioDevice), session.canAddInput(audioInput) else {
                print("[Recording] Error: cannot configure audio recording device")
                return
            }
            
            session.addInput(audioInput)
        }
        
        if content.options.kind == .photo,
           session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        //session.addOutput(fileOutput)

        if content.options.shouldProvideMetadata == true {
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
            }

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
            metadataOutput.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: CameraContent.Options.FocusRect)
        }
        
        // Only adjust mirroring for front camera, never for back camera.
        if position == .front, let connection = fileOutput.connection(with: .video) {
           connection.automaticallyAdjustsVideoMirroring = false
           connection.isVideoMirrored = true
        }
        
        session.commitConfiguration()
        
        previewLayer.session = session
        
        session.startRunning()
    }
    
}

extension CameraContentView : AVCaptureMetadataOutputObjectsDelegate {
    
    
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        for object in metadataObjects {
            guard hasScannedMetadataObjects == false else {
                continue
            }
            
            guard let current = object as? AVMetadataMachineReadableCodeObject else {
                continue
            }
            
            guard current.type == AVMetadataObject.ObjectType.qr else {
                continue
            }
            
            guard let value = current.stringValue else {
                continue
            }
            
            guard let url = URL(string: value) else {
                continue
            }
            
            hasScannedMetadataObjects = true

            content.foundMetadataContentPublisher.send(url)
        }
    }
    
}

extension CameraContentView : AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("[Recording] Actually started")
        
        content.startedRecordingPublisher.send()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard isCancelled == false else {
            print("[Recording] Cancelled")
            return
        }
        
        print("[Recording] Finished")
        
        guard let transcodedOutputUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(UUID().uuidString + ".mp4") else {
            print("[Recording] Cannot finish recording")
            return
        }
        
        DispatchQueue.main.async {
            self.content.isSaving = true
        }
        
        let export = AVAssetExportSession(asset: AVAsset(url: outputFileURL), presetName: AVAssetExportPresetPassthrough)
        export?.outputFileType = .mp4
        export?.outputURL = transcodedOutputUrl
        
        export?.exportAsynchronously { [weak self] in
            DispatchQueue.main.async {
                if export?.error == nil && export?.status == .completed {
                   
                        self?.content.finishedRecordingPublisher.send(.init(url: transcodedOutputUrl,
                                                                            duration: output.recordedDuration,
                                                                            userInfo: self?.userInfo ?? [:]))
                        
                       
                    
                    
                    try? FileManager.default.removeItem(at: outputFileURL)
                    
                    print("[Recording] Handed over")
                }
                
                self?.content.isSaving = false
            }
        }
        
        userInfo = [:]
    }
    
}

extension CameraContentView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("{TEST} beginning capture")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        print("{TEST} \(error?.localizedDescription)")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil else {
            print("{TEST} 1")
            return
        }
        
        guard let photo = photo.fileDataRepresentation() else {
            print("{TEST} 2")
            return
        }
        
        guard let image = UIImage(data: photo) else {
            print("{TEST} 3")
            return
        }
        
        content.reducer?.send(CameraContent.Meta(image: image))
//        reducer?.send(Meta(image: image))
//        reducer = nil
    }
}
#endif
