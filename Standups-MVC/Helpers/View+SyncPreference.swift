import Foundation
import SwiftUI

struct PreferenceSyncPipe<Key: PreferenceKey> where Key.Value: Equatable {
    fileprivate var set: (Key.Value) -> Void
}
    

extension View {
    // propagate preferences up the tree in cases where it doesn't happen automatically, e.g. `.sheet` (intentional by Apple), `List` (Apple bug)
    func withChildPreference<Key: PreferenceKey, Content: View>(key: Key.Type = Key.self, @ViewBuilder from content: @escaping (PreferenceSyncPipe<Key>) -> Content) -> some View
    where Key.Value: Equatable {
     SyncPreferenceView<Key, Content>(content: content)
    }
    
    func syncPreference<Key: PreferenceKey>(using pipe: PreferenceSyncPipe<Key>) -> some View {
        onPreferenceChange(Key.self, perform: pipe.set)
    }
}

fileprivate struct SyncPreferenceView<Key: PreferenceKey, Content: View>: View where Key.Value: Equatable {
    @State private var value: Key.Value = Key.defaultValue
    @ViewBuilder var content: (PreferenceSyncPipe<Key>) -> Content
    var body: some View {
      let set = { nextValue in
        Key.reduce(value: &value) { nextValue } // We use Key.reduce here to allow using the same pipe on multiple children, just like the built-in mechanism.
    }
      return content(.init(set: set))
        .onPreferenceChange(Key.self, perform: set) // Also merge with preferences coming from content, don't override them. Idk if this will preserve the order correctly, but should be good enough if reduce doesn't care about order.
        .preference(key: Key.self, value: value)
    }
}
