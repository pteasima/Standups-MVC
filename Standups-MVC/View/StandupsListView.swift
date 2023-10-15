import SwiftUI
import SwiftData

struct StandupsListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var standups: [Standup]
    @State private var newStandup: Standup?
    
    @State private var titleBinding: TextFieldBinding = .init(id: "nope", text: .constant(""))
    var body: some View {
        NavigationStack {
            List {
                ForEach(standups) { standup in
                    Text(standup.title)
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
                }
            }
            .sheet(item: $newStandup) { standup in
                EditStandupView(standup: standup)
                    .onPreferenceChange(TextFieldBinding.self) { value in
                        titleBinding = value
                    }
            }
        }
        .preference(key: StatePreference.self, value: .init(id: "standups", value: standups))
        .preference(key: ButtonAction.self, value: .init(id: "Add Button") {
            addStandup()
        })
        .preference(key: TextFieldBinding.self, value: titleBinding)
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
