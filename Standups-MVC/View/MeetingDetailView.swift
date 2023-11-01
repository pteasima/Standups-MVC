import SwiftUI

struct MeetingDetailView: View {
  var meeting: Meeting
  var body: some View {
    List {
      Section {
        ForEach(meeting.standup?.attendees ?? []) { attendee in
          Text(attendee.name)
        }
      } header: {
        Text("Attendees")
      }
      Section {
        Text(meeting.transcript)
      } header: {
        Text("Transcript")
      }
    }
    .navigationTitle(Text(meeting.date, style: .date))
  }
}

#Preview {
  MeetingDetailView(meeting: .sample)
}
