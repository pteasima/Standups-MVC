import SwiftUI
import SwiftData

struct StandupsListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var standups: [Standup]
    @State private var newStandup: Standup?
    @State var path: [Standup] = []
    @State @Reference private var draftContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
    var body: some View {
        withChildPreference(key: TestPreference.self) { textFieldBindingPipe in
            NavigationStack(path: $path) {
                List {
                    ForEach(standups) { standup in
                        NavigationLink(value: standup) {
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
                    .syncPreference(using: textFieldBindingPipe)
                }
                .navigationDestination(for: Standup.self) { standup in
                    StandupDetailView(standup: standup)
                }
            }
            .transformPreference(TestPreference.self) {
              $0.values[\Self.standups] = standups
              $0.values[\Self.$path] = $path
            }
        }
    }
    
  @MainActor
  var addStandup: () -> Void {{
    let newStandup = Standup(title: "")
    draftContainer.mainContext.insert(newStandup)
    Task {
      try await Task.sleep() // Tiny delay is needed otherwise sheet will be presented twice. This only happens because draftContainer has just been created. While we could create it eagerly, this seems like an apple bug that might get resolved, so Im ok with this workaround.
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
