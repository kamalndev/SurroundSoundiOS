import SwiftUI
import SwiftData

@main
struct SurroundSoundApp: App {
    // declare stateobkects
    @StateObject private var auth:      AuthViewModel
    @StateObject private var artistVM:  ArtistListViewModel
    @StateObject private var concertVM: ConcertListViewModel

        init() {
        let authVM    = AuthViewModel()              // create concrete instance
        let artistVM  = ArtistListViewModel(auth: authVM)
        let concertVM = ConcertListViewModel(artistVM: artistVM)

        // inject each into its wrapper
        _auth      = StateObject(wrappedValue: authVM)
        _artistVM  = StateObject(wrappedValue: artistVM)
        _concertVM = StateObject(wrappedValue: concertVM)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .environmentObject(artistVM)
                .environmentObject(concertVM)
        }
        .modelContainer(for: [SavedConcert.self])
    }
}

