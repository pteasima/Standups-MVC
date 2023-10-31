import Foundation

struct SimpleError: LocalizedError {
  var errorDescription: String?
}

extension SimpleError {
  init(_ errorDescription: String) {
    self.init(errorDescription: errorDescription)
  }
}
