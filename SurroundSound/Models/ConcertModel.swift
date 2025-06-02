import SwiftUI
// concert model for upcoming events page
struct Concert: Identifiable, Decodable {
    
    // info needed from ticketmaster api response
    let id: String
    let name: String
    let date: Date
    let venue: String
    let latitude: Double
    let longitude: Double
    let url: URL
    
    
}
