import Foundation

extension Standup {
    static var sample: Standup {
      .init(title: "Sample Standup", attendees: [.sample])
    }
}

extension Attendee {
  static var sample: Attendee {
    .init(name: "Tomas Fuk")
  }
}
