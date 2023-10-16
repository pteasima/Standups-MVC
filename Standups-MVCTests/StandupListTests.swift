import XCTest
@testable import Standups_MVC_xrOS
import SwiftUI
import SwiftData

final class StandupListTests: XCTestCase {
    
    var window = UIWindow(frame: CGRect(origin: .zero, size: .init(width: 500, height: 500)))
    
    @MainActor
    func testAdd() async throws {
        struct TestView: View {
            @State private var standups: [Standup] = []
            @State private var addButtonAction = { }
            @State private var titleBinding: Binding<String> = .constant("")
            
            var body: some View {
                let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
                modelContainer.mainContext.insert(Standup.sample)
                return StandupsListView()
                    .modelContainer(modelContainer)
                    .task {
                        // test
                        try! await Task.sleep()
                        try! await Task.sleep()
                        
                        XCTAssertEqual(standups.map(\.title), ["Sample Standup"])
                        
                        addButtonAction()
                        try! await Task.sleep(until: .now + .seconds(1), clock: .suspending)
                        print("value", titleBinding.wrappedValue)
                        titleBinding.wrappedValue = "hello"
                        print("value", titleBinding.wrappedValue)
                        try! await Task.sleep(until: .now + .seconds(1), clock: .suspending)
                        print(standups)
                        XCTAssertEqual(standups.map(\.title).sorted(), ["hello", "Sample Standup"].sorted())
                    }
                    .onPreferenceChange(ButtonAction.self) { action in
                        addButtonAction = action.action
                    }
                    .onPreferenceChange(StatePreference.self) { value in
                        standups = value.value as! [Standup]
                    }
                    .onPreferenceChange(TextFieldBinding.self) { text in
                        titleBinding = text.text
                    }
            }
        }
        
        
        
        let v = TestView()
        let host = UIHostingController(rootView: v)
        window.rootViewController = host
        window.makeKeyAndVisible()
        
        try await Task.sleep(until: .now + .seconds(3))
    }
   
    
    @MainActor
    func testSelectRow() async throws {
        struct TestView: View {
            @State private var standups: [Standup] = []
            @State private var rowActions: [AnyHashable: () -> Void] = [:]
            
            var body: some View {
                let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
                [Standup.sample, Standup.sample].forEach(modelContainer.mainContext.insert)
                return StandupsListView()
                    .modelContainer(modelContainer)
                    .task {
                        // test
                        try! await Task.sleep()
                        try! await Task.sleep()
                        
                        rowActions[[AnyHashable(standups[1].id), \RowView.selectStandup]]?()
                        XCTAssertEqual(selectedStandup, standups[1].id)
                    }
                    .onPreferenceChange(StatePreference.self) { value in
                        standups = value.value as! [Standup]
                    }
                    .onPreferenceChange(RowButtonActions.self) { actions in
                        rowActions = actions.actions
                    }
            }
        }
        
        
        
        let v = TestView()
        let host = UIHostingController(rootView: v)
        window.rootViewController = host
        window.makeKeyAndVisible()
        
        try await Task.sleep(until: .now + .seconds(3))
    }
}
