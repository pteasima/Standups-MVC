import Foundation
import SwiftData

@Model
final class Meeting {
  var date: Date
  var transcript: String
  
  init(date: Date = .now, transcript: String = "") {
    self.date = date
    self.transcript = transcript
  }
}
