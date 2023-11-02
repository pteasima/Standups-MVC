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
        var standups: [Standup] {
          testPreference[\StandupsListView.standups]
        }
        
        try await Task.sleep()
        try await Task.sleep()

        XCTAssertEqual(standups.map(\.title), ["Daily Standup"])
        
        
        testPreference[\StandupsListView.addStandup]()
        try await Task.sleep(until: .now + .seconds(1), clock: .suspending)
        testPreference[\EditStandupView.$standup.title].wrappedValue = "hello"
        try await Task.sleep(until: .now + .seconds(0.5), clock: .suspending)
        testPreference[\EditStandupView.addAttendee]()
        try await Task.sleep(until: .now + .seconds(0.5), clock: .suspending)
        let id = testPreference[\EditStandupView.$standup].attendees.first!.id
        testPreference[\EditStandupView.$standup.attendees[unsafeID: id].name].wrappedValue = "Im the first attendee"
        try await Task.sleep(until: .now + .seconds(0.5), clock: .suspending)
        testPreference[\EditStandupView.save]()
        try await Task.sleep(until: .now + .seconds(0.5), clock: .suspending)
        XCTAssertEqual(standups.map(\.title).sorted(), ["Daily Standup", "hello"].sorted())
        XCTAssertEqual(standups.first(where: { $0.title == "hello" })!.attendees.map(\.name), ["Im the first attendee"])
      }
  }
  
  @MainActor
  func testAddWithValidatedAttendees() async throws {
    let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
    modelContainer.mainContext.insert(Standup.sample)
    try await StandupsListView()
      .modelContainer(modelContainer)
      .testTask { $testPreference in
        var standups: [Standup] {
          testPreference[\StandupsListView.standups]
        }
        
        try await Task.sleep()
        try await Task.sleep()

        XCTAssertEqual(standups.map(\.title), ["Daily Standup"])
        
        
        testPreference[\StandupsListView.addStandup]()
        try await Task.sleep(until: .now + .seconds(1), clock: .suspending)
        testPreference[\EditStandupView.$standup.title].wrappedValue = "hello"
        try await Task.sleep(until: .now + .seconds(0.5), clock: .suspending)
        testPreference[\EditStandupView.addAttendee]()
        try await Task.sleep()
        testPreference[\EditStandupView.addAttendee]()
        try await Task.sleep(until: .now + .seconds(0.5), clock: .suspending)
        let id = testPreference[\EditStandupView.$standup].attendees.first!.id
        testPreference[\EditStandupView.$standup.attendees[unsafeID: id].name].wrappedValue = "    "
        try await Task.sleep(until: .now + .seconds(0.5), clock: .suspending)
        testPreference[\EditStandupView.save]()
        try await Task.sleep(until: .now + .seconds(0.5), clock: .suspending)
        XCTAssertEqual(standups.map(\.title).sorted(), ["Daily Standup", "hello"].sorted())
        //both attendees didn't pass validation but a default one with empty name was added
        XCTAssertEqual(standups.first(where: { $0.title == "hello" })!.attendees.map(\.name).sorted(), [""].sorted())
        
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
            try await Task.sleep()
            try await Task.sleep()
            
            XCTAssertEqual([Standup](), testPreference[\StandupsListView.$path].wrappedValue)
            testPreference[\StandupsListView.$path].wrappedValue = [testPreference[\StandupsListView.standups][0]]
            try await Task.sleep(until: .now + .seconds(1))
            testPreference[\StandupDetailView.edit]()
            try await Task.sleep(until: .now + .seconds(1))
            testPreference[\EditStandupView.$standup.title].wrappedValue = "hey"
            try await Task.sleep(until: .now + .seconds(1))
            XCTAssertEqual(testPreference[\StandupsListView.standups][0].title, "hey")
          }
         
  }
}

// pointfreeco/SyncUps have other tests. Some of these don't make sense for SwiftData (e.g. decoding), but others might be useful (e.g. test save).
