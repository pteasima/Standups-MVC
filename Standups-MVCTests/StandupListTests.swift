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
      @State private var standups: [Standup] = []
      @State private var addButtonAction = { }
      @State private var saveAction = { }
      @State private var titleBinding: Binding<String> = .constant("")
      
      var body: some View {
        return StandupsListView()
          .modelContainer(modelContainer)
          .task {
            // test
            try! await Task.sleep()
            try! await Task.sleep()

            XCTAssertEqual(standups.map(\.title), ["Daily Standup"])
            
            addButtonAction()
            try! await Task.sleep(until: .now + .seconds(1), clock: .suspending)
            titleBinding.wrappedValue = "hello"
            try! await Task.sleep(until: .now + .seconds(1), clock: .suspending)
            saveAction()
            try! await Task.sleep(until: .now + .seconds(1), clock: .suspending)
            XCTAssertEqual(standups.map(\.title).sorted(), ["Daily Standup", "hello"].sorted())
          }
          .onPreferenceChange(ButtonAction.self) { action in
            addButtonAction = action.actions["Add"] ?? { }
            saveAction = action.actions[\EditStandupView.save] ?? { }
          }
          .onPreferenceChange(StatePreference.self) { value in
            standups = value.value as! [Standup]
          }
          .onPreferenceChange(TextFieldBinding.self) { text in
            titleBinding = text.text
          }
      }
    }
    
    let v = TestView(modelContainer: modelContainer)
    let host = UIHostingController(rootView: v)
    window.rootViewController = host
    window.makeKeyAndVisible()
    
    try await Task.sleep(until: .now + .seconds(3))
  }
  
  
  @MainActor
  func testEdit() async throws {
    struct TestView: View {
      @State private var standups: [Standup] = []
      @State private var path: Binding<AnyHashable> = .constant("nope")
      @State private var editButtonAction: () -> Void = { }
      @State private var titleBinding: Binding<String> = .constant("")
      
      var body: some View {
        let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
        [Standup.sample, Standup.sample].forEach(modelContainer.mainContext.insert)
        return StandupsListView()
          .modelContainer(modelContainer)
          .task {
            // test
            try! await Task.sleep()
            try! await Task.sleep()
            
            XCTAssertEqual([Standup](), path.wrappedValue)
            path.wrappedValue = [standups[1]]
            try! await Task.sleep()
            editButtonAction()
            try! await Task.sleep()
            titleBinding.wrappedValue = "hey"
            try! await Task.sleep()
            XCTAssertEqual(standups[1].title, "hey")
            
          }
          .onPreferenceChange(StatePreference.self) { value in
            standups = value.value as! [Standup]
          }
          .onPreferenceChange(StateBindingPreference.self, perform: {
            path = $0.value
          })
          .onPreferenceChange(ButtonAction.self, perform: { value in
            print(value.actions)
            editButtonAction = value.actions["Edit"] ?? {}
          })
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
}
