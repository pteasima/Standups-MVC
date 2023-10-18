import Foundation
import SwiftData

@Model
final class Attendee {
  var name = ""
  
  init(name: String = "") {
    self.name = name
  }
}
