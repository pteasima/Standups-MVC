import Foundation
import SwiftUI

struct ButtonAction: Equatable, PreferenceKey {
    static func == (lhs: ButtonAction, rhs: ButtonAction) -> Bool {
        Set(lhs.actions.keys) == Set(rhs.actions.keys)
    }

    var actions: [AnyHashable: () -> Void] = [:]
    static var defaultValue: Self { .init() }
    static func reduce(value: inout Self, nextValue: () -> Self) {
      //TODO: maybe this is still buggy?
        value.actions = value.actions.merging(nextValue().actions) { $1 }
    }
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


