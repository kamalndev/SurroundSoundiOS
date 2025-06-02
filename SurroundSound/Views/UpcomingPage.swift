import SwiftUI
// show nearby concerts
struct UpcomingPage: View {
    // shared concertlistviewmodel
    @EnvironmentObject var vm: ConcertListViewModel

    var body: some View {
        NavigationStack {
            VStack {
                //distance slider
                VStack(spacing: 10) {
                    Text("Search Distance: \(Int(vm.radiusMiles)) miles")
                        .font(.caption)
                    Slider(value: $vm.radiusMiles, in: 10...150, step: 10)
                        .onChange(of: vm.radiusMiles) { _ in
                            vm.scheduleReload()
                        }
                }
                .padding()

                
                if vm.isLoading {
                    ProgressView().frame(maxHeight: .infinity)
                } else if vm.concerts.isEmpty {
                    // when no results
                    Text("No matching concerts in this area.")
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                    Spacer()
                } else {
                    // list of concerts, tapping once sends to concertdetailview
                    List(vm.concerts) { show in
                        NavigationLink {
                            ConcertDetailView(concert: show)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(show.name).font(.headline)
                                Text(show.venue)
                                Text(show.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                       
                    }
                }
            }
            .navigationTitle("Upcoming Concerts") // title
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { vm.requestLocation() } // ask for location
        }
    }
}

