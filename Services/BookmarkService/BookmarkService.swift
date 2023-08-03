import Granite

struct BookmarkService: GraniteService {
    @Service(.online) var center: Center
}
