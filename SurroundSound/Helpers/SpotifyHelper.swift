import SwiftUI
// gets the top artist using the spotify token
struct SpotifyHelper {
    static func fetchTopArtists(using token: String) async throws -> [Artist] {
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host = SpotifyAPI.apiHost
        comps.path = "/v1/me/top/artists"
        comps.queryItems = [.init(name: "limit", value: "20")]
        
        var req = URLRequest(url: comps.url!)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: req)
        struct Root: Decodable { let items: [Artist] }
        return try JSONDecoder().decode(Root.self, from: data).items
    }
}
