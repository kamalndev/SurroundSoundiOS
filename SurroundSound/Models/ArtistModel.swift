import SwiftUI

// model for an artist, to be used for the artists page when getting top aritsts from user

struct Artist: Identifiable, Decodable {
    let id: String
    let name: String
    let images: [ImageInfo]?
    
    struct ImageInfo: Decodable {
        let url: URL
    }
    var imageURL: URL? { images?.first?.url }
    
}
