import XCTest
@testable import Standups_MVC
import SwiftUI
import SwiftData

final class StandupListTests: XCTestCase {
    
    var window = UIWindow(frame: CGRect(origin: .zero, size: .init(width: 500, height: 500)))
    
    @MainActor
    func testAdd() async throws {
        struct TestView: View {
            @State private var standups: [Standup] = []
            @State private var addButtonAction = { }
            
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
                        print(standups)
                        XCTAssertEqual(standups.map(\.title).sorted(), ["", "Sample Standup"].sorted())
                    }
                    .onPreferenceChange(ButtonAction.self) { action in
                        addButtonAction = action.action
                    }
                    .onPreferenceChange(StatePreference.self) { value in
                        standups = value.value as! [Standup]
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
