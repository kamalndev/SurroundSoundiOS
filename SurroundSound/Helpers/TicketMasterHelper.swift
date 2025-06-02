import Foundation

enum TicketmasterHelper {

    static func fetchConcerts(
        for artist: String,
        lat: Double,
        lon: Double,
        radiusMiles: Int = 50
    ) async throws -> [Concert] {

        let path = TicketmasterAPI.eventsPath(
            artist: artist,
            lat: lat,
            lon: lon,
            radiusMiles: radiusMiles) + "&classificationName=music&size=100"

        let url = URL(string: "https://\(TicketmasterAPI.apiHost)\(path)")!
        let (data, _) = try await URLSession.shared.data(from: url)

        // Try to decode, but fall back to [] if schema mismatch
        guard
            let root = try? JSONDecoder.ticketmaster.decode(Root.self, from: data)
        else { return [] }
        
        
        // had problems with duplicate events being shown with fees, such as parking fee or service fee, so added this to get rid of those
        return root._embedded.events.compactMap { ev in
            if ev.name.localizedCaseInsensitiveContains("fee") { return nil }
            guard
                let venue = ev._embedded.venues.first,
                let loc   = venue.location,
                let url   = URL(string: ev.url)
            else { return nil }

            return Concert(
                id: ev.id,
                name: ev.name,
                date: ev.dates.start.dateTime,
                venue: venue.name,
                latitude: Double(loc.latitude) ?? 0,
                longitude: Double(loc.longitude) ?? 0,
                url: url
            )
        }
    }


    private struct Root: Decodable {
        let _embedded: EventsWrap
    }
    private struct EventsWrap: Decodable { let events: [Event] }
    private struct Event: Decodable {
        let id: String
        let name: String
        let url: String
        let dates: Dates
        let _embedded: VenuesWrap
    }
    private struct Dates: Decodable { let start: Start }
    private struct Start: Decodable { let dateTime: Date }
    private struct VenuesWrap: Decodable { let venues: [Venue] }
    private struct Venue: Decodable {
        let name: String
        let location: Location?
    }
    private struct Location: Decodable {
        let latitude: String
        let longitude: String
    }
}

private extension JSONDecoder {
    static var ticketmaster: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }
}

