import XCTest

#if os(xrOS)
@testable import Standups_MVC_xrOS
#elseif os(iOS)
@testable import Standups_MVC_iOS
#endif

import SwiftUI
import SwiftData

final class StandupListTests: XCTestCase {
    
  @MainActor
  func testAdd() async throws {
    let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
    modelContainer.mainContext.insert(Standup.sample)
    try await StandupsListView()
      .modelContainer(modelContainer)
      .testTask { $testPreference in
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
  }
  
  
  @MainActor
  func testEdit() async throws {
    let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
    //This test sometimes fails if we have multiple standups 🤔
    [Standup.sample].forEach(modelContainer.mainContext.insert)
    try await StandupsListView()
          .modelContainer(modelContainer)
          .testTask { $testPreference in
            // test
            try! await Task.sleep()
            try! await Task.sleep()
            
            XCTAssertEqual([Standup](), testPreference[\StandupsListView.$path].wrappedValue)
            testPreference[\StandupsListView.$path].wrappedValue = [testPreference[\StandupsListView.standups][0]]
            try! await Task.sleep(until: .now + .seconds(1))
            testPreference[\StandupDetailView.edit]()
            try! await Task.sleep(until: .now + .seconds(1))
            testPreference[\EditStandupView.$standup.title].wrappedValue = "hey"
            try! await Task.sleep(until: .now + .seconds(1))
            XCTAssertEqual(testPreference[\StandupsListView.standups][0].title, "hey")
          }
         
  }
}

extension View {
  @MainActor
  func testTask(_ task: @MainActor @escaping (Binding<TestPreference>) async throws -> Void) async throws {
    let testedView = modifier(
      TestTaskViewModifier(task: task)
    )
    let host = UIHostingController(rootView: testedView)
    testWindow.rootViewController = host
    testWindow.makeKeyAndVisible()
    
    try await Task.sleep(until: .now + .seconds(4)) //TODO: wait for test task to finish
  }
}


struct TestTaskViewModifier: ViewModifier {
  @State private var testPreference: TestPreference = .init()
  var task: @MainActor (Binding<TestPreference>) async throws -> Void
  func body(content: Content) -> some View {
    content
      .onPreferenceChange(TestPreference.self, perform: { value in
        testPreference = value
      })
      .task {
        do {
          try await task($testPreference)
        } catch {
          XCTFail(error.localizedDescription)
        }
      }
  }
}

// this needs to be the real app key window on some platforms, custom one has problems
var testWindow: UIWindow {
  (UIApplication.shared.connectedScenes.first as! UIWindowScene).windows.first!
}

