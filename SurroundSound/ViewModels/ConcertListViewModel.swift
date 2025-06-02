import SwiftUI
import CoreLocation

@MainActor
final class ConcertListViewModel: NSObject, ObservableObject {

    // list of concerts to display
    @Published var concerts: [Concert] = []
    @Published var isLoading = false
    @Published var error: String?
    
    @Published var radiusMiles: Double = 50       // attached to slider

    private let artistVM: ArtistListViewModel
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?


    private var reloadWorkItem: DispatchWorkItem?

    // need artist view model so we know which artist to get shows for
    init(artistVM: ArtistListViewModel) {
        self.artistVM = artistVM
        super.init()
        // talking to core location to call delegate methods
        locationManager.delegate = self
    }

    // public api
    // called when upcoming page is loadded
    func requestLocation() {
        // prompts user the first time for location
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    // whenever distance slider moves, called
    func scheduleReload() {
        // cancel pending reloads
        reloadWorkItem?.cancel()
        // call loadconcerts after a slight pause
        let work = DispatchWorkItem { [weak self] in self?.loadConcerts() }
        reloadWorkItem = work
        
        // schedule on main queue after the delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: work)
    }

    // fetching shows for the artists
    private func loadConcerts() {
        // quit if location isnt updated yet
        guard let loc = userLocation else { return }
        isLoading = true
        
        Task {
            var all: [Concert] = []
            // for each artist, called the ticketmasterhelper, and fetch concerts
            for artist in artistVM.artists {
                if let shows = try? await TicketmasterHelper.fetchConcerts(
                    for: artist.name,
                    lat: loc.latitude,
                    lon: loc.longitude,
                    radiusMiles: Int(radiusMiles)) {
                    all.append(contentsOf: shows)
                }
            }

            // taking out duplicates
            var dict = [String: Concert]()
            for show in all {
                let key = "\(show.name)|\(show.venue)|\(show.date)"
                dict[key] = show
            }
            // sort by dates and assigned to the earlier @published propertyy
            concerts = dict.values.sorted { $0.date < $1.date }
            isLoading = false
        }
    }
}


extension ConcertListViewModel: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            // called when user authroization changes
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()   //once have permission, ask for location
            case .denied, .restricted:
                error = "Location access is required to find nearby concerts."
            default:
                break
            }
        }
    // called once app has location
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first?.coordinate
        loadConcerts()
    }
    // called if location fetch fails
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        self.error = error.localizedDescription
    }
}

