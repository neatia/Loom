import Granite

extension Bookmark {
    struct DidAppear: GraniteReducer {
        typealias Center = Bookmark.Center
        
        func reduce(state: inout Center.State) {
            print("[Bookmark] appeared")
        }
    }
}
