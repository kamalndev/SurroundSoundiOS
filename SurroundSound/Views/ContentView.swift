import SwiftUI


struct ContentView: View {
    // lets us read issignedin from the shared authviewmdodel
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        // shows main tab view if user is signed in, and login view otherwise
        if auth.isSignedIn {
            MainTabView()           
        } else {
            LoginView()
        }
    }
}
