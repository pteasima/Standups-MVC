import Foundation
import SwiftData

@Model
final class Meeting {
  var date: Date
  var transcript: String
  var standup: Standup?
  
  init(date: Date = .now, transcript: String = "", standup: Standup? = nil) {
    self.date = date
    self.transcript = transcript
  }
}
