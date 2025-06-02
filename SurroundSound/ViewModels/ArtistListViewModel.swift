import SwiftUI

@MainActor
class ArtistListViewModel: ObservableObject {
    // holds array of top artists returned by spotfy
    // @published so swift views observing this vm will rerender automatically
    @Published var artists: [Artist] = []
    // for toggling loading spinner in ui
    @Published var isLoading = false
    // any error message to show in alerts
    @Published var error: String?
    
    // so authviewmodel can fetch accessToken, private because only this class should ask for tokens
    private let auth: AuthViewModel // to get access token
    init(auth: AuthViewModel) {self.auth = auth}
    
    // load users top 20 artists via spotify api
    func load() {
        // make sure we have a token, or else prompt user to log in first
        guard let token = auth.accessToken else {
            error = "Please log in first."
            return
        }
        
        isLoading = true
        // async fetch
        Task {
            // fetch the top artists and assign to the @published var
            do {
                artists = try await SpotifyHelper.fetchTopArtists(using: token)
            } catch {
                self.error = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
}
