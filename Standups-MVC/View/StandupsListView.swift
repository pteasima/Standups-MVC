import SwiftUI
import SwiftData

enum Destination: Hashable {
  case detail(Standup)
  case record(Standup)
}

struct StandupsListView: View {
  
  
  @Environment(\.modelContext) var modelContext
  @Query var standups: [Standup]
  @State private var newStandup: Standup?
  @State var path: [Destination] = []
  var body: some View {
    //TODO: this `withChildPreference` wrapper seems to also be needed for the addStandup action form the toolbar (and possibly others) to properly propagate. I don't yet undrestand why those are affected.
    withChildPreference(key: TestPreference.self) { testPreferencePipe in
      NavigationStack(path: $path) {
        List {
          ForEach(standups) { standup in
            NavigationLink(value: Destination.record(standup)) {
              VStack(alignment: .leading, spacing: 20) {
                Text(standup.title)
                  .font(.headline)
                HStack {
                  Label(standup.attendees.count.formatted(), systemImage: "person.3")
                  
                  Spacer()
                  Label(standup.duration.formatted(), systemImage: "timer")
                    .labelStyle(.trailingIcon)
                }
                .font(.caption)
              }
            }
            .foregroundColor(standup.theme.accentColor)
            .listRowBackground(Rectangle().fill(standup.theme.mainColor.gradient))
          }
          .onDelete { indexSet in
            indexSet.map { standups[$0] }.forEach(modelContext.delete)
          }
        }
        .navigationTitle("Standups")
        .toolbar {
          ToolbarItem(placement: .automatic) {
            Button(action: testable.addStandup) {
              Text("+")
            }
          }
        }
        .sheet(item: $newStandup) { standup in
          EditStandupView(standup: standup, onSave: {
            modelContext.insert(standup.deepCopy)
          })
          .modelContext(standup.modelContext!)
          .syncPreference(using: testPreferencePipe)
        }
        .navigationDestination(for: Destination.self) { destination in
          switch destination {
          case .detail(let standup):
            StandupDetailView(standup: standup)
          case .record(let standup):
            RecordMeetingView(standup: standup)
          }
        }
      }
      .transformPreference(TestPreference.self) {
        $0.values[\Self.standups] = standups
        $0.values[\Self.$path] = $path
        $0.values[\Self.self] = self //easiest way to test anything
      }
    }
  }
  
  @MainActor
  var addStandup: () -> Void {{
    let draftContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
    let newStandup = Standup(title: "")
    draftContainer.mainContext.insert(newStandup)
    Task {
      try await Task.sleep() // Tiny delay is needed otherwise sheet will be presented twice. This only happens because draftContainer has just been created. Im ok with this workaround.
      // NOTE: When I tried creating draftContainer eagerly, it messed with the seemingly unrelated `AppTests.testRecord()` test. It crashed when appending a recorded Meeting to the Standup. This is a known coredata issue from having multiple core data stacks https://stackoverflow.com/questions/40597981/unacceptable-type-of-value-for-to-one-relationship-property-user-desired-t . Looks like SwiftData suffers from this, and so using a second draftContainer (although recommended by Apple), might not be a robust solution. Rn tests pass because we don't create a draftContainer in that particular test.
      self.newStandup = newStandup
    }
  }}
}

#Preview {
  let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
  modelContainer.mainContext.insert(Standup.sample)
  return StandupsListView()
    .modelContainer(modelContainer)
}
