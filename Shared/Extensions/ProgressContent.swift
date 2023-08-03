import Foundation

#if os(iOS)
import UIKit

final class ProgressContent : ObservableObject {
    
    @Published var value : Double = 0.0
    
    fileprivate var progress : Progress? = nil
    fileprivate var observer : NSKeyValueObservation? = nil
    
    deinit {
        end()
    }
    
    func begin() -> Progress {
        let progress = Progress.fractional()
        
        self.observer = progress.observe(\.fractionCompleted, options: .new) { _, change in
            DispatchQueue.main.async {
                self.value = change.newValue ?? 0.0
            }
        }
        
        self.progress = progress
        
        return progress
    }
    
    func end() {
        self.observer?.invalidate()
        
        self.observer = nil
        self.progress = nil
    }
    
}

extension Progress {
    
    fileprivate static let Multiplier : Int64 = 100
    
    static func fractional() -> Progress {
        Progress(totalUnitCount: Self.Multiplier)
    }
    
    func child(fraction : Double) -> Progress {
        let child = Progress(totalUnitCount: Self.Multiplier,
                             parent: self,
                             pendingUnitCount: Int64(fraction * Double(Self.Multiplier)))
        return child
    }
    
    func update(fraction : Double) {
        completedUnitCount = Int64(fraction * Double(Self.Multiplier))
    }
    
    func update(fraction : Float) {
        update(fraction: Double(fraction))
    }
    
}
#endif
