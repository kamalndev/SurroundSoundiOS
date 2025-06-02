import SwiftUI
import SwiftData
import EventKit
// shows went and want to go saved concerts
struct SavedPage: View {
    // fetch all savedconcert models sorted by date
    @Query(sort: \SavedConcert.date, order: .forward) private var savedConcerts: [SavedConcert]
    // swift data insert delete
    @Environment(\.modelContext) private var modelContext

    // Calendar alert to users can add to calendar
    @State private var showCalendarAlert = false
    @State private var calendarAlertTitle = ""
    @State private var calendarAlertMessage = ""

    var body: some View {
        NavigationStack {
            List {
                // concerts already went to
                Section("Went") {
                    ForEach(went) { sc in
                        SavedRow(sc)
                            .swipeActions(edge: .leading) {
                                // Move back to “want”
                                Button("Want") {
                                    move(sc, to: "want")
                                }
                                .tint(.yellow)
                            }
                            .swipeActions(edge: .trailing) {
                                // Delete entirely
                                Button("Delete", role: .destructive) {
                                    modelContext.delete(sc)
                                }
                                // And add to calendar
                                Button {
                                    addToCalendar(sc)
                                } label: {
                                    Label("Calendar", systemImage: "calendar.badge.plus")
                                }
                                .tint(.green)
                            }
                    }
                }
                // concerts user marks want to go to
                Section("Want to Go") {
                    ForEach(want) { sc in
                        SavedRow(sc)
                            .swipeActions(edge: .leading) {
                                // Move to “went”
                                Button("Went") {
                                    move(sc, to: "went")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing) {
                                // Delete
                                Button("Delete", role: .destructive) {
                                    modelContext.delete(sc)
                                }
                                // Add to calendar
                                Button {
                                    addToCalendar(sc)
                                } label: {
                                    Label("Calendar", systemImage: "calendar.badge.plus")
                                }
                                .tint(.green)
                            }
                    }
                }
            }
            .navigationTitle("Saved Concerts")
            .listStyle(.insetGrouped)
            .alert(isPresented: $showCalendarAlert) {
                Alert(
                    title: Text(calendarAlertTitle),
                    message: Text(calendarAlertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // Helpers
    // filter by went and want
    private var went: [SavedConcert] {
        savedConcerts.filter { $0.status == "went" }
    }
    private var want: [SavedConcert] {
        savedConcerts.filter { $0.status == "want" }
    }
    // moving between sections
    private func move(_ sc: SavedConcert, to newStatus: String) {
        sc.status = newStatus
    }
    // adding concert to user calendar
    private func addToCalendar(_ sc: SavedConcert) {
        let store = EKEventStore()
        store.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                guard granted, error == nil else {
                    calendarAlertTitle = "Permission Denied"
                    calendarAlertMessage = "Cannot add to calendar without permission."
                    showCalendarAlert = true
                    return
                }

                let event = EKEvent(eventStore: store)
                event.title = sc.name
                event.startDate = sc.date
                event.endDate = sc.date.addingTimeInterval(2*60*60)
                event.notes = sc.venue
                event.calendar = store.defaultCalendarForNewEvents

                do {
                    try store.save(event, span: .thisEvent)
                    calendarAlertTitle = "Added!"
                    calendarAlertMessage = "Concert added to Calendar."
                } catch {
                    calendarAlertTitle = "Error"
                    calendarAlertMessage = "Could not save event: \(error.localizedDescription)"
                }
                showCalendarAlert = true
            }
        }
    }
    // helper to render each row
    @ViewBuilder
    private func SavedRow(_ sc: SavedConcert) -> some View {
        VStack(alignment: .leading) {
            Text(sc.name).font(.headline)
            Text(sc.venue)
            Text(sc.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption).foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }
}

