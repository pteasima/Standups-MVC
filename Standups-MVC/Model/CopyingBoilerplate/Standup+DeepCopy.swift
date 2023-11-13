import Foundation

extension Standup {
  var deepCopy: Standup {
    Standup(title: title, duration: duration, attendees: attendees.map(\.deepCopy))
  }
}

