import SwiftUI

// single row showing artist image and name
struct ArtistRow: View {
    // artist model from parent list
    let artist: Artist

    var body: some View {
        HStack(spacing: 16) {
            // for downloading and caching artist image url
            AsyncImage(url: artist.imageURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Color.gray.opacity(0.3)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(Circle()) // makles picture round
            
            // artost name text
            Text(artist.name)
                .font(.headline)

            Spacer() // pushes content to left
        }
        .padding(.vertical, 4) // padding between rows
    }
}

// page listing top 20 artits
struct ArtistsPage: View {
    // gets artistlistviewmodel from environment
    // holds published artists, isloading, and error
    @EnvironmentObject var vm: ArtistListViewModel

    var body: some View {
        NavigationStack {
            if vm.isLoading {
                ProgressView()
                    .navigationTitle("Your Top 20 Artists")
                    .frame(alignment:.center)
                    
            } else {
                // once loaded, show list of artistrows
                List(vm.artists) { artist in
                    ArtistRow(artist: artist)
                }
                .listStyle(.plain)
                .navigationTitle("Your Top 20 Artists")
                .navigationBarTitleDisplayMode(.inline)            }
        }
        .onAppear {
            if vm.artists.isEmpty { vm.load() }
        }
    }
}

