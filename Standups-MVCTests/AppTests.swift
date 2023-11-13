import XCTest

#if os(xrOS)
@testable import Standups_MVC_xrOS
#elseif os(iOS)
@testable import Standups_MVC_iOS
#endif

import SwiftUI
import SwiftData

final class AppTests: XCTestCase {
  @MainActor
  func testRecordWithTranscript() async throws {
    let modelContainer = try! ModelContainer(for: Standup.self, Meeting.self, configurations: .init(isStoredInMemoryOnly: true))
    let theStandup = Standup(title: "X", attendees: [.init(name: "A"), .init(name: "B")])
    modelContainer.mainContext.insert(theStandup)
    try await StandupsListView()
      .modelContainer(modelContainer)
      .environment(\.[key: \SpeechRecognizer.self], SpeechRecognizer(authorizationStatus: {
        .authorized
      }, requestAuthorization: {
        .authorized
      }, startTask: { _ in
        AsyncThrowingStream { continuation in
          continuation.yield(.init(bestTranscription: Transcription(formattedString: "Im the transcript."), isFinal: true))
          continuation.finish()
        }
      }))
      .testTask { $testPreference in
        try await Task.sleep()
        try await Task.sleep()
        testPreference[\StandupsListView.self].path = [.detail(theStandup), .record(theStandup)]
        try await Task.sleep(until: .now + .seconds(0.5))
        testPreference[\RecordMeetingView.self].next()
        try await Task.sleep(until: .now + .seconds(0.5))
        testPreference[\RecordMeetingView.self].next()
        try await Task.sleep(until: .now + .seconds(0.5))
        XCTAssertEqual(testPreference[\StandupDetailView.self].standup.meetings.first!.transcript, "Im the transcript.")
      }
  }
}
