import Granite

struct ContentService: GraniteService {
    @Service(.online) var center: Center
}
