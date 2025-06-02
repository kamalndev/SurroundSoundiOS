import SwiftUI
import MapKit
import SwiftData
import EventKit

struct ConcertDetailView: View {
    let concert: Concert // when user taps row in upcoming concert page

    // persistence, dismissal
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Fetch all saved concerts
    @Query(sort: \SavedConcert.date, order: .forward)
    private var savedConcerts: [SavedConcert]
    
    // local ui
    @State private var region: MKCoordinateRegion // map center and zoom
    // for adding to calendar
    @State private var calendarAlertTitle = ""
    @State private var calendarAlertMessage = ""
    @State private var showCalendarAlert = false
    @State private var showShareSheet = false

    // find out whether this concert is already saved and with which status
    private var existing: SavedConcert? {
        savedConcerts.first { $0.id == concert.id }
    }
    
    init(concert: Concert) {
        self.concert = concert
        _region = State(initialValue: MKCoordinateRegion( // initialize state region with concert coordinates
            center: CLLocationCoordinate2D(
                latitude: concert.latitude,
                longitude: concert.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }

    var body: some View {
        ScrollView {
            // map preview
            Map(coordinateRegion: $region,
                annotationItems: [concert]) { c in
                MapMarker(coordinate: CLLocationCoordinate2D(
                    latitude: c.latitude,
                    longitude: c.longitude
                ))
            }
            .frame(height: 220)
            .cornerRadius(12)
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                Text(concert.name)
                    .font(.title2).bold()
                Text(concert.venue)
                    .font(.headline)
                Text(concert.date.formatted(date: .long, time: .shortened))
                // to get tickets
                Link("Get Tickets on Ticketmaster", destination: concert.url)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.top, 8)
                // all buttons, saving concert, add to calendar, and share
                Button {
                    toggleStatus("went")
                } label: {
                    let isWent = existing?.status == "went"
                    Label("Went", systemImage: isWent
                        ? "checkmark.circle.fill"
                        : "checkmark")
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    toggleStatus("want")
                } label: {
                    let isWant = existing?.status == "want"
                    Label("Want to Go", systemImage: isWant
                        ? "star.fill"
                        : "star")
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: addToCalendar) {
                    Label("Add to Calendar", systemImage: "calendar.badge.plus")

                }
                .buttonStyle(.borderedProminent)


                Button(action: { showShareSheet = true }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert(calendarAlertTitle, isPresented: $showCalendarAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(calendarAlertMessage)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [shareText])
        }
    }


    private var shareText: String {
        """
        \(concert.name) @ \(concert.venue)
        \(concert.date.formatted(date: .long, time: .shortened))
        """
    }

    private func toggleStatus(_ status: String) {
        if let sc = existing {
            modelContext.delete(sc)
        } else {
            let new = SavedConcert(
                id: concert.id,
                name: concert.name,
                date: concert.date,
                venue: concert.venue,
                status: status
            )
            modelContext.insert(new)
        }
    }

    private func addToCalendar() {
        let store = EKEventStore()
        store.requestWriteOnlyAccessToEvents { granted, error in
            DispatchQueue.main.async {
                guard granted, error == nil else {
                    calendarAlertTitle   = "Permission Denied"
                    calendarAlertMessage = "Cannot add to calendar without permission."
                    showCalendarAlert    = true
                    return
                }
                let ekEvent = EKEvent(eventStore: store)
                ekEvent.title = concert.name
                ekEvent.startDate = concert.date
                ekEvent.endDate = concert.date.addingTimeInterval(3600)
                ekEvent.notes = concert.venue
                ekEvent.calendar = store.defaultCalendarForNewEvents

                do {
                    try store.save(ekEvent, span: .thisEvent)
                    calendarAlertTitle   = "Event Added"
                    calendarAlertMessage = "Successfully added to your calendar."
                } catch {
                    calendarAlertTitle   = "Error"
                    calendarAlertMessage = "There was an error saving the event."
                }
                showCalendarAlert = true
            }
        }
    }
}

