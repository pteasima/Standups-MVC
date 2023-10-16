//
//  Standups_MVCApp.swift
//  Standups-MVC
//
//  Created by Petr Šíma on 13.10.2023.
//

import SwiftUI
import SwiftData

@main
struct Standups_MVCApp: App {
    var body: some Scene {
        WindowGroup {
//            Playground()
//                .modelContainer(for: AModel.self, inMemory: true)
            Text("app")
//            StandupsListView()
//                .modelContainer(for: Standup.self, inMemory: true)
//            TestView(modelContainer: modelContainer)
        }
    }
}

@MainActor
let modelContainer: ModelContainer = {
    let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
    [Standup.sample, Standup.sample].forEach(modelContainer.mainContext.insert)
        return modelContainer
}()

struct TestView: View {
    var modelContainer: ModelContainer
    @State private var standups: [Standup] = []
    @State private var rowActions: [AnyHashable: () -> Void] = [:]
    
    var body: some View {
        Self._printChanges()
        return StandupsListView()
//                    .onPreferenceChange(RowButtonActions.self) { actions in
//                        print("test", actions)
//                        guard !actions.actions.isEmpty else { return } // !!! When `List` is used in the child view, it mysteriously clears the preference after setting it. As a workaround, we ignore subsequent empty values.
//                        rowActions = actions.actions
//                    }
            .modelContainer(modelContainer)
            .task {
                try! await Task.sleep()
                try! await Task.sleep(until: .now + .milliseconds(500))
                
                
//                        rowActions[[AnyHashable(standups[1].id), \RowView.selectStandup]]?()
                try! await Task.sleep()
                try! await Task.sleep(until: .now + .milliseconds(100))
//                        XCTAssertEqual(selectedStandup, standups[1].id)
            }
            .onPreferenceChange(APreference.self, perform: {
                print("apreference", $0)
            })
//                    .onPreferenceChange(StatePreference.self) { value in
//                        standups = value.value as! [Standup]
//                    }
    }
}
