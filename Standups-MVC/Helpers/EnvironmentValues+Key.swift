import SwiftUI

extension EnvironmentValues {
  subscript<Key: EnvironmentKey>(key _: KeyPath<Key,Key> = \Key.self) -> Key.Value {
    get { self[Key.self] }
    set { self[Key.self] = newValue }
  }
}

extension Environment {
  init<Key: EnvironmentKey>(_: Key.Type) where Key.Value == Value {
    self.init(\.[key: \Key.self])
  }
}
