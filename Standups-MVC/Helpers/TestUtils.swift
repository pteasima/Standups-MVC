import Foundation
import SwiftUI

struct TestPreference: Equatable, PreferenceKey {
  // !!! if a non-hashable value changes, it might not update the preference. Idk how much of a problem that is in practice. Worst-case, the burden will be put on the user to only include Hashable preferences.
  static func == (lhs: TestPreference, rhs: TestPreference) -> Bool {
    if Set(lhs.values.keys) != Set(rhs.values.keys) {
      return false
    }
    for (lhk, lhv) in lhs.values {
      guard let rhv = rhs.values[lhk] else { return false }
      if let lhv = lhv as? AnyHashable,
         let rhv = rhv as? AnyHashable,
         lhv != rhv {
        return false
      }
    }
    return true
  }
  
  var values: [AnyHashable: Any] = [:]
  static var defaultValue: Self { .init() }
  static func reduce(value: inout Self, nextValue: () -> Self) {
    value.values = value.values.merging(nextValue().values) { $1 }
  }
  subscript<Base, Subject>(id: KeyPath<Base, Subject>) -> Subject { values[id] as! Subject }
}

struct StatePreference: Equatable, PreferenceKey {
    typealias ID = String
    var id: ID
    var value: AnyHashable
    static var defaultValue: Self = .init(id: "nope", value: "stupid")
    
    static func reduce(value: inout StatePreference, nextValue: () -> StatePreference) {
        value = nextValue()
    }
    
}

struct TextFieldBinding: Equatable, PreferenceKey {
    static func == (lhs: TextFieldBinding, rhs: TextFieldBinding) -> Bool {
        lhs.id == rhs.id
    }
    
    typealias ID = String
    var id: ID
    var text: Binding<String>
    static var defaultValue: Self { .init(id: "nope", text: .constant("")) }
    static func reduce(value: inout Self, nextValue: () -> Self) {
        value = nextValue()
    }
}

struct StateBindingPreference: Equatable, PreferenceKey {
    static func == (lhs: StateBindingPreference, rhs: StateBindingPreference) -> Bool {
        lhs.id == rhs.id
    }
    
    typealias ID = AnyHashable
    var id: ID
    var value: Binding<AnyHashable>
    static var defaultValue: Self = .init(id: "nope", value: .constant("stupid"))
    
    static func reduce(value: inout StateBindingPreference, nextValue: () -> StateBindingPreference) {
        value = nextValue()
    }
    
    
}

struct ErasedWithPreference<Content: View>: View {
  @Environment(TestableID.self) var testableID
  var content: Content
  var id: AnyHashable
  var value: Any
  var body: some View {
    content
      .testableID(nil)
      .preference(key: TestPreference.self, value: .init(values: [testableID ?? id : value]))
  }
}

extension Button {
  init<RawLabel: View>(action: WithPath<() -> Void>, @ViewBuilder label: () -> RawLabel) where Label ==  ErasedWithPreference<RawLabel> {
    self.init(action: action.wrappedValue) {
      ErasedWithPreference(content: label(), id: action.id, value: action.wrappedValue)
    }
  }
}
//extension TextField {
//  init<RawLabel: View>(text: WithPath<Binding<String>>, @ViewBuilder label: () -> RawLabel) where Label ==  ErasedWithPreference<RawLabel> {
//    self.init(text: text.wrappedValue) {
//      //BROKEN: This wont propagate out
//      ErasedWithPreference(label: label(), id: text.id, value: text.wrappedValue)
//    }
//  }
//}
//unfortunatelly, for TextField we cannot attach the preference to the label (it doesn't propagate). So a separate struct was needed. This shouldn't be the norm, most of the time we should be able to use a custom init like Button
struct TestableTextField<Label: View>: View {
  var text: WithPath<Binding<String>>
  @ViewBuilder var label: () -> Label
  var body: some View {
    TextField(text: text.wrappedValue) {
      label()
    }
    .preference(key: TestPreference.self, value: .init(values: [text.id: text.wrappedValue]))
  }
}

@dynamicMemberLookup
struct WithPath<WrappedValue> {
  var id: AnyKeyPath
  var wrappedValue: WrappedValue
  
  subscript<Subject>(dynamicMember keyPath: KeyPath<WrappedValue, Subject>) -> WithPath<Subject> {
    // Try to append the paths. I wonder if WithPath could have remembered original Base and be type-safe
    .init(id: id.appending(path: keyPath) ?? keyPath, wrappedValue: wrappedValue[keyPath: keyPath])
  }
}

@dynamicMemberLookup
struct Testable<Base> {
  var base: Base
  subscript<Subject>(dynamicMember keyPath: KeyPath<Base, Subject>) -> WithPath<Subject> {
    .init(id: keyPath, wrappedValue: base[keyPath: keyPath])
  }
  
  
}


extension View {
  var testable: Testable<Self> {
    .init(base: self)
  }
}

enum TestableID: EnvironmentKey {
  static var defaultValue: AnyHashable? = nil
}
extension View {
  func testableID(_ id: AnyHashable?) -> some View {
    self
      .environment(\.[key: \TestableID.self], id)
  }
}


extension View {
  func withTestPreference<V: View>(for view: V) -> some View {
    self
      .transformPreference(TestPreference.self) {
        $0.values[\V.self] = view
      }
  }
}
