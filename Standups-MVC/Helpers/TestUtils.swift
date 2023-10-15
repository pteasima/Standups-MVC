import Foundation
import SwiftUI

struct ButtonAction: Equatable, PreferenceKey {
    static func == (lhs: ButtonAction, rhs: ButtonAction) -> Bool {
        lhs.id == rhs.id
    }
    
    typealias ID = String
    var id: ID
    var action: () -> Void = {}
    static var defaultValue: Self { .init(id: "nope") }
    static func reduce(value: inout Self, nextValue: () -> Self) {
        let v = value
        let n = nextValue()
        value = .init(id: v.id + n.id) { //TODO: use a dictionary of multiple actions
            v.action()
            n.action()
        }
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

struct RowButtonActions: Equatable, PreferenceKey {
    static func == (lhs: RowButtonActions, rhs: RowButtonActions) -> Bool {
        Set(lhs.actions.keys) == Set(rhs.actions.keys)
    }
    
    var actions: [AnyHashable: () -> Void] = [:]
    static var defaultValue: Self { .init() }
    static func reduce(value: inout Self, nextValue: () -> Self) {
        value.actions = value.actions.merging(nextValue().actions) { $1 }
    }
}
