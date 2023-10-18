import SwiftUI
import SwiftData

struct StandupsListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var standups: [Standup]
    @State private var newStandup: Standup?
    
    @State var path: [Standup] = []
    var body: some View {
        withChildPreference(key: TextFieldBinding.self) { textFieldBindingPipe in
            NavigationStack(path: $path) {
                List {
                    ForEach(standups) { standup in
                        NavigationLink(value: standup) {
                            Text(standup.title)
                        }
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
                    EditStandupView(standup: standup)
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
    
    private func addStandup() {
        let newStandup = Standup(title: "")
        modelContext.insert(newStandup)
        self.newStandup = newStandup
    }
}

#Preview {
    let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
    modelContainer.mainContext.insert(Standup.sample)
    return StandupsListView()
        .modelContainer(modelContainer)
}
