import Granite
import Foundation

extension AnalyzeService {
    struct GPT: GraniteReducer {
        typealias Center = AnalyzeService.Center
        
        struct Meta: GranitePayload {
            let prompt: String
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            let prompt = "hello"
            
            print("{TEST} prompt: \(prompt)")
//            
//            state.gpt.generate(text: prompt, nTokens: 50) { completion, time in
//                print("{TEST} result: \(completion)")
//            }
        }
    }
}
