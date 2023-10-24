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
            Slider(value: $standup.duration.seconds, in: 5...30, step: 1) {
              Text("Length")
            }
            Spacer()
            Text(standup.duration.formatted(.units()))
          }
          
          //TODO: build a proper picker (none of the built-in styles are good and custom styles are not possible yet)
          Picker("Theme", selection: $standup.theme) {
            ForEach(Theme.allCases) { theme in
              Text(theme.name)
//                .background { theme.mainColor } //menu picker style doesn't honor this anyway
            }
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

fileprivate extension Duration {
  var seconds: Double {
    get { Double(self.components.seconds / 60) }
    set { self = .seconds(newValue * 60) }
  }
}


#Preview {
  let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
  let standup = Standup.sample
  modelContainer.mainContext.insert(standup)
  return EditStandupView(standup: standup)
    .modelContainer(modelContainer)
}
