import SwiftUI
import SwiftData

struct StandupsListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var standups: [Standup]
    @State private var newStandup: Standup?
    @State var path: [Standup] = []
    @State @Reference private var draftContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
    var body: some View {
        withChildPreference(key: TextFieldBinding.self) { textFieldBindingPipe in
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
                        Button {
                            addStandup()
                        } label: {
                            Text("+")
                        }
                        .preference(key: ButtonAction.self, value: .init(actions: ["Add" : {
                          addStandup()
                        }]))
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
            .preference(key: StatePreference.self, value: .init(id: "standups", value: standups))
            .preference(key: StateBindingPreference.self, value: .init(id: \Self.path, value: Binding {
                path
            } set: { (value: AnyHashable) in
                path = value as! [Standup]
            }))
            .onChange(of: path) {
                print("path", $0, $1)
            }
        }
    }
    
  @MainActor
  private func addStandup() {
    let draftContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
    let newStandup = Standup(title: "")
    draftContainer.mainContext.insert(newStandup)
    Task {
      try await Task.sleep() // Tiny delay is needed otherwise sheet will be presented twice. This only happens because draftContainer has just been created. While we could create it eagerly, this seems like an apple bug that might get resolved, so Im ok with this workaround.
      self.newStandup = newStandup
    }
  }
}

#Preview {
    let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
    modelContainer.mainContext.insert(Standup.sample)
    return StandupsListView()
        .modelContainer(modelContainer)
}
