//
//  ContentView.swift
//  Standups-MVC
//
//  Created by Petr Šíma on 13.10.2023.
//

import SwiftUI
import RealityKit
import RealityKitContent

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

struct ContentView: View {
    @State var value: Int = 42
    var body: some View {
        VStack {
            Button {
                value += 1
            } label: {
                Text("tap me")
            }
            .preference(key: ButtonAction.self, value: .init(id: "tap me button") {
                value += 1
            })
            
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Hello, world!")
        }
        .preference(key: StatePreference.self, value: .init(id: "the value", value: value))
        .padding()
    }
}

struct Preview: View {
    @State private var tapMeAction: () -> Void = { }
    @State private var theValue: Int = -1
    var body: some View {
        ContentView()
//            .onAppear {
//                //TODO: assert ui snapshot
//            }
            .task {
                // test
                try! await Task.sleep()
                try! await Task.sleep()
                
                assert(theValue == 42)
                tapMeAction()
                tapMeAction()
                
                try! await Task.sleep()
                assert(theValue == 44)
                
            }
            .onPreferenceChange(ButtonAction.self) { action in
                tapMeAction = action.action
            }
            .onPreferenceChange(StatePreference.self) { value in
                theValue = value.value as! Int
            }
            .overlay(alignment: .leading) {
                VStack {
                    Button {
                        tapMeAction()
                    } label: {
                        Text("Tap it")
                    }
                    Text(String(describing: theValue))
                }
            }
    }
}
#Preview(windowStyle: .automatic) {
    Preview()
}
