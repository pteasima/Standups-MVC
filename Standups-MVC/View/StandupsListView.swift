import SwiftUI
import SwiftData

struct StandupsListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var standups: [Standup]
    @State private var newStandup: Standup?
    
    @State private var detail: Standup?
    
    var body: some View {
        withChildPreference(key: TextFieldBinding.self) { textFieldBindingToken in
            NavigationStack {
                VStack {
                    ForEach(standups) { standup in
                        RowView(standup: standup)
                            .transformPreference(RowButtonActions.self) { value in
                                let selectStandupAction = value.actions[\RowView.selectStandup]
                                value.actions[\RowView.selectStandup] = nil
                                let id = [AnyHashable(standup.id), \RowView.selectStandup]
                                value.actions[id] = selectStandupAction
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
                    }
                }
                .sheet(item: $newStandup) { standup in
                    EditStandupView(standup: standup)
                        .syncPreference(using: textFieldBindingToken)
                }
            }
            .preference(key: StatePreference.self, value: .init(id: "standups", value: standups))
            .preference(key: ButtonAction.self, value: .init(id: "Add Button") {
                addStandup()
            })
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


struct RowView: View {
    var standup: Standup
    var body: some View {
        Button {
            selectStandup()
//            detail = standup
        } label: {
            Text(standup.title)
        }
        .preference(key: RowButtonActions.self, value: .init(actions: [\Self.selectStandup : selectStandup]))
    }
    
    var selectStandup: () -> Void {
        {
            selectedStandup = standup.id
        }
    }
}

var selectedStandup: Standup.ID?
