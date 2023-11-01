import Foundation

extension Standup {
    static var sample: Standup {
      .init(title: "Daily Standup", attendees: [.sample, .sample2])
    }
}

extension Attendee {
  static var sample: Attendee {
    .init(name: "Tomas Fuk")
  }
  static var sample2: Attendee {
    .init(name: "John Doe")
  }
}

extension Meeting {
  static var sample: Meeting {
    .init(date: .distantPast, transcript: "Sample transcript")
  }
}
