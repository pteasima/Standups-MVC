import Foundation
import SwiftData
import SwiftUI

@Model
final class Standup {
    var title: String
//  var duration: Duration = Duration.seconds(60 * 5) // will cause a crash, SwiftData doesn't see to support custom Codable types well yet.
  var duration: TimeInterval = 60*5
  @Relationship
  var attendees: [Attendee] = []
  //  var meetings: IdentifiedArrayOf<Meeting> = []
  var theme: Theme = Theme.bubblegum
  init(title: String = "", duration: TimeInterval = 60*5, attendees: [Attendee] = [], theme: Theme = .bubblegum) {
    self.title = title
    self.duration = duration
    self.attendees = attendees
  }
}
