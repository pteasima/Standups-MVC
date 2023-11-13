import SwiftUI
import SwiftData

struct StandupDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Bindable var standup: Standup
  @State var isEditing: Bool = false
  var body: some View {
    withChildPreference(key: TestPreference.self) { testPreferencePipe in
      List {
        Section {
          NavigationLink(value: Destination.record(standup)) {
            Label("Start Meeting", systemImage: "timer")
              .bold()
          }
          HStack {
            Label("Length", systemImage: "clock")
            Spacer()
            Text(standup.duration.formatted(.units()))
          }
          HStack {
            Label("Theme", systemImage: "paintpalette")
            Spacer()
            Text(standup.theme.name)
              .foregroundStyle(standup.theme.accentColor)
              .padding(4)
              .background {
                RoundedRectangle(cornerRadius: 4).fill(standup.theme.mainColor.gradient) 
              }
          }
        } header: {
          Text("Standup Info")
        }
        
        if !standup.meetings.isEmpty {
          Section {
            ForEach(standup.meetings) { meeting in
              NavigationLink {
                MeetingDetailView(meeting: meeting)
              } label: {
                Text(meeting.date, style: .date)
              }
            }
            .onDelete { indexSet in
              indexSet.map { standup.meetings[$0] }.forEach(modelContext.delete)
            }
          } header: {
            Text("Past Meeetings")
          }
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
          Button(action: testable.edit) {
            Text("Edit")
          }
        }
      }
      .sheet(isPresented: $isEditing) {
        EditStandupView(standup: standup)
          .syncPreference(using: testPreferencePipe)
      }
    }
    .withTestPreference(for: self)
  }
  
  var edit: () -> Void {{
    isEditing = true
  }}
  
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
