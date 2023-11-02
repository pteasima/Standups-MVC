import XCTest
import SwiftUI
#if os(xrOS)
@testable import Standups_MVC_xrOS
#elseif os(iOS)
@testable import Standups_MVC_iOS
#endif

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

