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
