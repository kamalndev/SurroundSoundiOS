// most of this code i made with extensive help from tutorials and online guides,
// such as this one - 

import SwiftUI
import AuthenticationServices
import CryptoKit

@MainActor // with async stuff, makes sure this happens first
final class AuthViewModel: NSObject, ObservableObject {   
    
    // state objects for view
    @Published var isSignedIn = false
    @Published var error: AuthError? = nil
    
    // token for api calls
    private(set) var accessToken: String?
    // code verififer , which we later exchange for token
    private var codeVerifier: String?
    
    // public api called from loginview
    func login() {
        // clear all previous errors
        error = nil
        
        // generate verifier and challenge
        let verifier = Self.randomURLSafe(length: 64) // random code verifier
        codeVerifier = verifier
        
        // sha256 hash of verifier
        let challenge = Data(SHA256.hash(data: Data(verifier.utf8)))
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        // build /authorize url
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host   = SpotifyAPI.authHost // from apiconstants
        comps.path   = "/authorize"
        comps.percentEncodedQuery = SpotifyAPI.authQuery(codeChallenge: challenge)
        guard let authURL = comps.url else { return }
        
        // open safari for login, and so user can grant permissions
        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: "surroundsound") { [weak self] callbackURL, err in
                guard let self else { return }
                // handle errors like user cancelling
                if let err {
                    self.error = AuthError(message: err.localizedDescription)
                    return
                }
                // get code query parameter from
                guard let code = URLComponents(url: callbackURL!, resolvingAgainstBaseURL: false)?
                        .queryItems?.first(where: { $0.name == "code" })?.value else {
                    self.error = AuthError(message: "callback error")
                    return
                }
                // now exchange that code for access tokn
                Task { await self.exchange(code: code) }
        }
        session.presentationContextProvider = self
        
        // start aswebauthenticationsession
        session.start()
    }
    
    // code exchange to token
    private func exchange(code: String) async {
        // get earlier generated codeverifier
        guard let verifier = codeVerifier else { return }
        
        // post request to /api/token
        var req = URLRequest(url: URL(string: "https://\(SpotifyAPI.authHost)/api/token")!)
        req.httpMethod = "POST"
        req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        
        let form: [String:String] = [
            "client_id"    : SpotifyAPI.clientId,
            "grant_type"   : "authorization_code",
            "code"         : code,
            "redirect_uri" : SpotifyAPI.redirectUri,
            "code_verifier": verifier
        ]
        req.httpBody = form
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        do {
            // send the request
            let (data, _) = try await URLSession.shared.data(for: req)
            // decode the recieved json
            let token = try JSONDecoder().decode(Token.self, from: data)
            // signed in is true, and get accesstoken in variable
            accessToken = token.access_token
            isSignedIn  = true
        } catch let err {                            // **avoid naming collision**
            self.error = AuthError(message: err.localizedDescription)
        }
    }
}

// swiftui bridge for aswebauthenticationservice
extension AuthViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
       // key window to present safari sheet
        UIApplication.shared.windows.first { $0.isKeyWindow }!
    }
}

//helpers
// this decodes the accesstoken that we get from spotify
private struct Token: Decodable { let access_token: String }

// error message so can present an alert
struct AuthError: Identifiable { let id = UUID(); let message: String }

// build a url safe string of given length
private extension AuthViewModel {
    static func randomURLSafe(length: Int) -> String {
        let chars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return String((0..<length).map { _ in chars.randomElement()! })
    }
}

