import XCTest

#if os(xrOS)
@testable import Standups_MVC_xrOS
#elseif os(iOS)
@testable import Standups_MVC_iOS
#endif

import SwiftUI
import SwiftData

final class StandupListTests: XCTestCase {
  
  var window: UIWindow {
    (UIApplication.shared.connectedScenes.first as! UIWindowScene).windows.first!
  }
  
  @MainActor
  func testAdd() async throws {
    let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
    modelContainer.mainContext.insert(Standup.sample)
    struct TestView: View {
      var modelContainer: ModelContainer
      @State private var testPreference: TestPreference = .init()
      
      var body: some View {
        return StandupsListView()
          .modelContainer(modelContainer)
          .task {
            // test
            try! await Task.sleep()
            try! await Task.sleep()

            XCTAssertEqual(testPreference[\StandupsListView.standups].map(\.title), ["Daily Standup"])
            
            testPreference[\StandupsListView.addStandup]()
            try! await Task.sleep(until: .now + .seconds(1), clock: .suspending)
            testPreference[\EditStandupView.$standup.title].wrappedValue = "hello"
            try! await Task.sleep(until: .now + .seconds(1), clock: .suspending)
            testPreference[\EditStandupView.save]()
            try! await Task.sleep(until: .now + .seconds(1), clock: .suspending)
            let standups = testPreference[\StandupsListView.standups]
            XCTAssertEqual(standups.map(\.title).sorted(), ["Daily Standup", "hello"].sorted())
          }
          .onPreferenceChange(TestPreference.self, perform: { value in
            testPreference = value
          })
      }
    }
    
    let v = TestView(modelContainer: modelContainer)
    let host = UIHostingController(rootView: v)
    window.rootViewController = host
    window.makeKeyAndVisible()
    
    try await Task.sleep(until: .now + .seconds(5))
  }
  
  
  @MainActor
  func testEdit() async throws {
    struct TestView: View {
//      @State private var editButtonAction: () -> Void = { }
//      @State private var titleBinding: Binding<String> = .constant("")
      @State private var testPreference: TestPreference = .init()
      
      var body: some View {
        let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
        //This test sometimes fails if we have multiple standups 🤔
        [Standup.sample].forEach(modelContainer.mainContext.insert)
        return StandupsListView()
          .modelContainer(modelContainer)
          .task {
            // test
            try! await Task.sleep()
            try! await Task.sleep()
            
            XCTAssertEqual([Standup](), testPreference[\StandupsListView.$path].wrappedValue)
            testPreference[\StandupsListView.$path].wrappedValue = [testPreference[\StandupsListView.standups][0]]
            try! await Task.sleep()
            testPreference[\StandupDetailView.edit]()
            try! await Task.sleep()
            testPreference[\EditStandupView.$standup.title].wrappedValue = "hey"
            try! await Task.sleep()
            XCTAssertEqual(testPreference[\StandupsListView.standups][0].title, "hey")
          }
          .onPreferenceChange(TestPreference.self, perform: { value in
            testPreference = value
          })
      }
    }
    
    let v = TestView()
    let host = UIHostingController(rootView: v)
    window.rootViewController = host
    window.makeKeyAndVisible()
    
    try await Task.sleep(until: .now + .seconds(4))
  }
}
