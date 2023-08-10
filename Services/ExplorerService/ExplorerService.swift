import Granite

struct ExplorerService: GraniteService {
    @Service var center: Center
}

extension Services {
    
    var explorer : ExplorerService {
        get {
            self[ExplorerService.self]
        }
        set {
            self[ExplorerService.self] = newValue
        }
    }
    
}
