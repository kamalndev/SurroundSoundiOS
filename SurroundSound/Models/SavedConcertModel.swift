import SwiftUI
import SwiftData
// saved concert model, for the saved concerts page
@Model
class SavedConcert {
    @Attribute(.unique) var id: String
    var name: String
    var date: Date
    var venue: String
    var status: String    // "went" or "want"

    init(
        id: String,
        name: String,
        date: Date,
        venue: String,
        status: String
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.venue = venue
        self.status = status
    }
}

