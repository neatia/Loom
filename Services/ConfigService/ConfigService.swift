import Granite

struct ConfigService: GraniteService {
    @Service(.online) var center: Center
    
}
