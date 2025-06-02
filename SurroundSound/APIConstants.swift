import SwiftUI

enum SpotifyAPI {
    static let apiHost = "api.spotify.com"
    static let clientId = "9f85c4cd5d334779a84a13ddeb2be11e"
    static let authHost = "accounts.spotify.com"
    // static let clientSecret = "11c372634ab6425a971a17ea3344c163"
    static let redirectUri = "surroundsound://callback"
    static let responseType = "code"
    static let scopes = "user-top-read"
    
    static var authParams = [
        "response_type" : responseType,
        "client_id": clientId,
        "redirect_uri": redirectUri,
        "scope": scopes
    ]
    
    static func authQuery(codeChallenge: String) -> String {
        "client_id=\(clientId)&response_type=code&redirect_uri=\(redirectUri)&scope=\(scopes)&code_challenge_method=S256&code_challenge=\(codeChallenge)"
    }
}

enum TicketmasterAPI {
    static let apiHost = "app.ticketmaster.com"
    static let apiKey = "xOtzDnMQDz7Z1EKTHrKuMv0VJ8qn0jvc"
    // static let secretKey = "ctfj0euG4y4rAWYj"
    static func eventsPath(artist: String, lat: Double, lon: Double, radiusMiles: Int = 50) -> String
    {
        "/discovery/v2/events.json?apikey=\(apiKey)" +
        "&keyword=\(artist.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) ?? "")" +
        "&latlong=\(lat),\(lon)" +
        "&radius=\(radiusMiles)"
    }
}

