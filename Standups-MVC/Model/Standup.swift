import Foundation
import SwiftData

@Model
final class Standup {
    var title: String
    
    init(title: String) {
        self.title = title
    }
}
