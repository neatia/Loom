import Granite

struct DraftService: GraniteService {
    @Service(.online) var center: Center
}
