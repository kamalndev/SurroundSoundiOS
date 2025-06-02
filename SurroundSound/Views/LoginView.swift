import SwiftUI

private let themeBlack = Color(red:   0/255, green:  8/255, blue:  7/255)
private let themeGreen = Color(red: 191/255, green:240/255, blue:212/255)
private let themeGray  = Color(red: 135/255, green:151/255, blue:175/255)
private let spotifyGreen = Color(red: 30/255, green: 215/255, blue:96/255)

struct LoginView: View {
    // authviewmodel created in the app
    @EnvironmentObject var auth: AuthViewModel
    // local state to show/hide spinner
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // background color
            themeGreen.ignoresSafeArea()
            
            VStack(spacing: 10) {
                // title
                Text("SurroundSound")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(spotifyGreen)
                    .padding(10)
                // subtitle
                Text("Find Nearby Concerts")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(themeBlack)
                Text("Featuring Your Favorite Artists")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(themeBlack)
                
                // pushes login button down
                Spacer()
                Spacer()
                
                // login button
                Button {
                    isLoading = true
                    auth.login() // calls the authviewmodel  login function
                } label: {
                    // ui for login button
                    HStack(spacing: 10) {
                        Image(systemName: "music.note.list")
                            .font(.title2)
                        Text("Login With Spotify")
                            .font(.title2)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(spotifyGreen)
                    .foregroundColor(themeBlack)
                }
                .disabled(isLoading)
                .opacity(isLoading ? 0.5 : 1)
                
                Spacer()
            }
            .padding()
        }
        // alert if login fails
        .alert(item: $auth.error) { err in
            // reset spinner if error
            isLoading = false
            return Alert(
                title: Text("Login failed"),
                message: Text(err.message),
                dismissButton: .default(Text("OK"))
            )
        }
        // turn off spinner once sign‑in succeeds
        .onChange(of: auth.isSignedIn) { _ in
            isLoading = false
        }

        
    }
}

