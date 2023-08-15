import Granite

struct LoomService: GraniteService {
    @Service(.online) var center: Center
}
