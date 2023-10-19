import SwiftUI
import SwiftData

struct EditStandupView: View {
  @Environment(\.dismiss) private var dismiss
  @Bindable var standup: Standup
  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField(text: $standup.title) {
            Text("Title")
          }
          HStack {
            Slider(value: $standup.duration, in: 5...30, step: 1) {
              Text("Length")
            }
            Spacer()
            Text(standup.duration.formatted())
          }
        }
        Section {
          //TODO: this binding strugless with the changing order (once I ended up with two rows for the same attendee). Should be fixed once order is stable.
          ForEach($standup.attendees) { $attendee in
            TextField("Attendee Name", text: $attendee.name)
          }
          Button {
            addAttendee()
          } label: {
            Text("Add Attendee")
          }
        } header: {
          Text("Attendees")
        }
      }
      .navigationTitle(standup.title)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button {
            //TODO: undo via undo manager
            dismiss()
          } label: {
            Text("Cancel")
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button {
            dismiss()
          } label: {
            Text("Done")
          }
        }
      }
    }
    .preference(key: TextFieldBinding.self, value: .init(id: "Title Field", text: $standup.title))
  }
  
  var addAttendee: () -> Void {{
    standup.attendees.append(.init())
  }}
}

#Preview {
  let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
  let standup = Standup.sample
  modelContainer.mainContext.insert(standup)
  return EditStandupView(standup: standup)
    .modelContainer(modelContainer)
}
