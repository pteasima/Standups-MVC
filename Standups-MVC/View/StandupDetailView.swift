import SwiftUI
import SwiftData

struct StandupDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Bindable var standup: Standup
  @State var isEditing: Bool = false
  var body: some View {
    withChildPreference(key: TextFieldBinding.self) { textFieldPipe in
      List {
        Section {
          Button {
            startMeeting()
          } label: {
            Label("Start Meeting", systemImage: "timer")
              .bold()
          }
        Label("Length", systemImage: "clock")
          HStack {
            Label("Theme", systemImage: "paintpalette")
            Spacer()
            Text(standup.theme.name)
              .foregroundStyle(standup.theme.accentColor)
              .padding(4)
              .background {
                standup.theme.mainColor
                  .clipShape(RoundedRectangle(cornerRadius: 4))
              }
          }
        } header: {
          Text("Standup Info")
        }
        Section {
          ForEach(standup.attendees) { attendee in
            Label(attendee.name, systemImage: "person")
          }
        } header: {
          Text("Attendees")
        }
        Section {
          Button {
            delete()
          } label: {
            Text("Delete")
              .frame(maxWidth: .infinity)
              .foregroundStyle(.red)
              .bold()
          }
        }
      }
      .navigationTitle(standup.title)
      .toolbar {
        ToolbarItem {
          Button {
            isEditing = true
          } label: {
            Text("Edit")
          }
        }
      }
      .sheet(isPresented: $isEditing) {
        EditStandupView(standup: standup)
          .syncPreference(using: textFieldPipe)
      }
    }
    .preference(key: ButtonAction.self, value: .init(actions: [ "Edit" : { isEditing = true } ]))
  }
  
  var startMeeting: () -> Void {
    {
      
    }
  }
  
  var delete: () -> Void {
    {
      modelContext.delete(standup)
      dismiss()
    }
  }
}

#Preview {
  let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
  let standup = Standup.sample
  modelContainer.mainContext.insert(standup)
  return NavigationStack {
    StandupDetailView(standup: standup)
      .modelContainer(modelContainer)
  }
}
