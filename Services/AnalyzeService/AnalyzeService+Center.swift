import Granite
import SwiftUI

extension AnalyzeService {
    struct Center: GraniteCenter {
        public enum AnalyzeStatus : String, AnyStatus {
            case loading
            case summarizing
        }
        
        struct State: GraniteState {
            
            var source: Source = .empty
            var summary: [Phrase] = []
            var status: Status<AnalyzeStatus> = .init()
            
//            let model: GraniteML<MLMultiArray>? = GraniteML<MLMultiArray>(MiDaS.self, input: .buffer)
        }
        
        @Store public var state: State
        
        @Event var load: Load.Reducer
        @Event var gpt: GPT.Reducer
    }
}
