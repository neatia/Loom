#if os(iOS)
import Foundation
import AVFoundation
import Combine
import UIKit
import Granite

class CameraContent : ObservableObject {
    struct Meta: GranitePayload {
        let image: UIImage
    }
    
    struct Options {
        enum Kind {
            case photo
            case video
        }
        static var FocusRect: CGRect {
            let focusSize : CGFloat = 0.6 * min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            
            var focusRect = CGRect(x: 0, y: 0, width: focusSize, height: focusSize)
            focusRect.origin.x = (UIScreen.main.bounds.width - focusSize) / 2
            focusRect.origin.y = (UIScreen.main.bounds.height - focusSize) / 2 - 50.0
            
            return focusRect
        }
        
        var shouldProvideMetadata = false
        var kind: Kind = .photo
    }

    struct RecordingProperties {
        let duration : CMTime?
        let userInfo : [String : Any]
    }
    
    struct RecordingResult {
        let url : URL
        let duration: CMTime
        let userInfo : [String : Any]
    }
    
    @Published var isSaving = false
    @Published fileprivate(set) var isRecording = false
    @Published fileprivate(set) var recordedDurationInSeconds: Int = 0
    
    let takePhotoPublisher = PassthroughSubject<Void, Never>()
    
    let startRecordingPublisher = PassthroughSubject<RecordingProperties, Never>()
    let stopRecordingPublisher = PassthroughSubject<Void, Never>()
    let cancelRecordingPublisher = PassthroughSubject<Void, Never>()
    let setCameraPositionPublisher = PassthroughSubject<AVCaptureDevice.Position, Never>()
    
    let startedRecordingPublisher = PassthroughSubject<Void, Never>()
    let finishedRecordingPublisher = PassthroughSubject<RecordingResult, Never>()
    let foundMetadataContentPublisher = PassthroughSubject<URL, Never>()
    
    let options : Options
    
    fileprivate var cancellables = Set<AnyCancellable>()
    fileprivate var timerCancellable: Cancellable?
    
    let reducer: EventExecutable?
    
    init(options : Options = .init(), reducer: EventExecutable? = nil) {
        self.options = options
        self.reducer = reducer
    }
    
    func record(duration : CMTime?, userInfo : [String : Any]) {
        startRecordingPublisher.send(.init(duration: duration, userInfo: userInfo))
        
        isRecording = true
        
        finishedRecordingPublisher.sink { [weak self] _ in
            self?.isRecording = false
        }.store(in: &cancellables)
        
        recordedDurationInSeconds = 0
        
        self.timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] (output) in
                self?.recordedDurationInSeconds += 1
            })
    }
    
    func stopRecording() {
        stopRecordingPublisher.send()
        timerCancellable?.cancel()
    }
    
    func cancelRecording() {
        isRecording = false
        cancelRecordingPublisher.send()
        timerCancellable?.cancel()
        recordedDurationInSeconds = 0
    }
    
    func setCameraPosition(_ position: AVCaptureDevice.Position) {
        setCameraPositionPublisher.send(position)
    }
    
    func takePhoto() {
        takePhotoPublisher.send()
    }
}
#endif
