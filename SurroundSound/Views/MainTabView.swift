
import SwiftUI

private let themeBlack = Color(red:   0/255.0, green:   8/255.0, blue:   7/255.0)
private let themeGreen  = Color(red: 191/255.0, green: 240/255.0, blue: 212/255.0)
private let themeGray = Color(red: 135/255.0, green: 151/255.0, blue: 175/255.0)

struct MainTabView: View {
    // makes selected tab mint green
    init() {
        // makes tab bar background green
        UITabBar.appearance().backgroundColor = UIColor(themeGreen)
    }
    var body: some View {
        VStack(spacing: 5) {
            // 3 tab ui for top artists, upcoming concerts, and saved concerts
            TabView {
                ArtistsPage()
                    .tabItem {
                        Label("Artists", systemImage: "person.2.fill")
                        
                    }
                UpcomingPage()
                    .tabItem {
                        Label("Upcoming Concerts", systemImage: "ticket.fill")
                    }
                SavedPage()
                    .tabItem {
                        Label("Saved", systemImage: "star.fill")
                    }
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

