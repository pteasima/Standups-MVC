import Foundation
import SwiftUI
import SwiftData

enum StandupListTests {
    struct TestAdd: View {
        @State private var standups: [Standup] = []
        @State private var addButtonAction = { }
        
        var body: some View {
            let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
            modelContainer.mainContext.insert(Standup.sample)
            return StandupsListView()
            .modelContainer(modelContainer)
            //            .onAppear {
            //                //TODO: assert ui snapshot
            //            }
                .task {
                    // test
                    try! await Task.sleep()
                    try! await Task.sleep()
                    
                    assert(standups.map(\.title) == ["Sample Standup"])
                    
                    addButtonAction()
                    try! await Task.sleep(until: .now + .seconds(1), clock: .suspending)
                    print(standups)
                    assert(standups.map(\.title).sorted() == ["", "Sample Standup"].sorted())
                    print("Test Succeeded ✅")
                }
                .onPreferenceChange(ButtonAction.self) { action in
                    addButtonAction = action.action
                }
                .onPreferenceChange(StatePreference.self) { value in
                    standups = value.value as! [Standup]
                }
            
            //            .onPreferenceChange(StatePreference.self) { value in
            //                theValue = value.value as! Int
            //            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    StandupListTests.TestAdd()
}

struct ButtonAction: Equatable, PreferenceKey {
    static func == (lhs: ButtonAction, rhs: ButtonAction) -> Bool {
        lhs.id == rhs.id
    }
    
    typealias ID = String
    var id: ID
    var action: () -> Void = {}
    static var defaultValue: Self { .init(id: "nope") }
    static func reduce(value: inout Self, nextValue: () -> Self) {
        let v = value
        let n = nextValue()
        value = .init(id: v.id + n.id) { //TODO: use a dictionary of multiple actions
            v.action()
            n.action()
        }
    }
}

struct StatePreference: Equatable, PreferenceKey {
    typealias ID = String
    var id: ID
    var value: AnyHashable
    static var defaultValue: Self = .init(id: "nope", value: "stupid")
    
    static func reduce(value: inout StatePreference, nextValue: () -> StatePreference) {
        value = nextValue()
    }
    
}
