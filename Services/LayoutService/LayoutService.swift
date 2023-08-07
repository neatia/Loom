import Granite

struct LayoutService: GraniteService {
    @Service(.online) var center: Center
    
}
