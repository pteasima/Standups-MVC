import SwiftUI
import SwiftData

struct EditStandupView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Bindable var standup: Standup
  enum Field: Hashable {
    case title
    case attendee(PersistentIdentifier)
  }
  @FocusState var focusedField: Field?
//  @State private var color: Color = .red
  var onSave: (() -> Void)? = nil // when nil, this view only has a Done button (assumes edits are made live into the main modelContext). When not nil, it has Cancel and Save buttons. Idk if this is the best UX, but I wanted to show how easy live edits are (when editing from StandupDetailView) compared to the cumbersome copying to and from another modelContainer (when adding from StandupsListView).
  var body: some View {
    NavigationStack {
      Form {
        Section { 
          TestableTextField(text: WithPath(id: \Self.$standup.title, wrappedValue: $standup.title)) {
            Text("Title")
          }
          .focused($focusedField, equals: .title)
          HStack {
            //slider is buggy on xrOS, sometimes freezes UI
            Slider(value: $standup.duration.seconds, in: 5...30, step: 1) {
              Text("Length")
            }
            Spacer()
            Text(standup.duration.formatted(.units()))
          }
          
//          //TODO: build a proper picker (none of the built-in styles are good and custom styles are not possible yet)

          Picker("Theme", selection: $standup.theme) {
            ForEach(Theme.allCases) { theme in
//              HStack {
//                Circle()
//                  .foregroundStyle(theme.mainColor.gradient)
                Text(theme.name)
                  .foregroundStyle(theme.mainColor)
//              }
              .frame(maxWidth: .infinity, alignment: .center)
              .background(in: RoundedRectangle(cornerRadius: 20))
              .backgroundStyle(theme.mainColor.opacity(0.33).gradient)
//                .background { theme.mainColor.edgesIgnoringSafeArea(.all) } //menu picker style doesn't honor this anyway
            }
          }
          .pickerStyle(.wheel)
          .frame(height: 140)
//          ColorPicker("Theme", selection: $color)
          
        }
        Section {
          //TODO: this binding strugless with the changing order (once I ended up with two rows for the same attendee). Should be fixed once order is stable.
          ForEach($standup.attendees) { $attendee in
            TestableTextField(text: WithPath(id: \Self.$standup.attendees[unsafeID: attendee.id].name, wrappedValue: $attendee.name)) {
              Text("Attendee Name")
            }
            .focused($focusedField, equals: .attendee(attendee.id))
          }
          Button(action: testable.addAttendee) {
            Text("Add Attendee")
          }
        } header: {
          Text("Attendees")
        }
      }
      .navigationTitle(standup.title)
      .toolbar {
        if let _ = onSave {
          ToolbarItem(placement: .cancellationAction) {
            Button {
              dismiss()
            } label: {
              Text("Cancel")
            }
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(action: testable.save) {
            Text(onSave == nil ? "Done": "Save")
          }
        }
      }
      .transformPreference(TestPreference.self) {
        $0.values[\Self.$standup] = $standup
      }
    }
  }
  
  var addAttendee: () -> Void {{
    withAnimation {
      let newAttendee = Attendee()
      standup.attendees.append(newAttendee)
      focusedField = .attendee(newAttendee.id)
    }
  }}
  
  var save: () -> Void {{
    // apple/Scrumdinger doesn't validate attendees. We filter out unnamed ones and create a default unnamed one if there are no others, to match behavior of pointfreeco/SyncUps.
    standup.attendees = standup.attendees.filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    if standup.attendees.isEmpty {
      standup.attendees.append(.init(name: ""))
    }
    onSave?()
    dismiss()
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
