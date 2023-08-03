import Granite
import Foundation

extension AnalyzeService {
    struct Phrase: GraniteModel, Identifiable {
        let id: UUID
        let value: String
        init(value: String) {
            id = .init()
            self.value = value
        }
    }
    struct Summarize: GraniteReducer {
        typealias Center = AnalyzeService.Center
        
        @Event var response: SummarizeResponse.Reducer
        
        func reduce(state: inout Center.State) {
            
            let parts = state.source.parts
            let bodies = parts.flatMap { $0.body }.filter { $0.kind != .none && $0.content.isEmpty == false }
            let content = bodies.map { $0.content }.joined()
            
//            state.summary = bodies.flatMap { $0.content.summarize.map { result in Phrase(value: result) } }
            
//            state.summary = content.summarize.map { result in Phrase(value: result) }
//
//
            print("{TEST} Summarize \(content)")
            _ = Task {
                let similarityIndex = await SimilarityIndex(
                    model: MultiQAMiniLMEmbeddings(),
                    metric: EuclideanDistance()
                )
                
                await similarityIndex.addItem(
                    id: "id1",
                    text: content,
                    metadata: ["source": "example.pdf"]
                )
                let results = await similarityIndex.search("who is this about?")
                print(results.first?.text)
            }
            
            state.status -= .summarizing
        }
        
        var thread: DispatchQueue? {
            .global(qos: .background)
        }
    }
    
    struct SummarizeResponse: GraniteReducer {
        typealias Center = AnalyzeService.Center
        
        
//        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
//            guard let response = meta?.gptResponse else { return }
//            print("{TEST} \(response.count)")
//            for choice in response {
//                print("{TEST} \(choice.text)")
//            }
            
//            state.summary = response.map { result in Phrase(value: result.text) }
//
//
//            state.status -= .summarizing
        }
    }
}
