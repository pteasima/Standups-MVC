import Foundation
import SwiftData
import SwiftUI

@Model
final class Standup {
    var title: String
//  var duration: Duration = Duration.seconds(60 * 5) // will cause a crash, SwiftData doesn't seem to support custom Codable types well yet.
  var durationInSeconds: Int64 = 60*5
  @Relationship
  var attendees: [Attendee] = []
  @Relationship
  var meetings: [Meeting] = []
  var theme: Theme = Theme.bubblegum
  init(title: String = "", duration: Duration = .seconds(60*5), attendees: [Attendee] = [], meetings: [Meeting] = [], theme: Theme = .bubblegum) {
    self.title = title
    self.duration = duration
    self.attendees = attendees
  }
}

extension Standup {
  var duration: Duration {
    get { .seconds(durationInSeconds) }
    set { durationInSeconds = newValue.components.seconds }
  }
  var durationPerAttendee: Duration {
    self.duration / self.attendees.count
  }
}
