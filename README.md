#  Standups-MVC

A SwiftData-backed clone of apple/Scrumdinger and pointfreeco/SyncUps, written in MVC architecture (with added testability as an afterthought 🙂).

## Motivation

In its current state, SwiftUI itself isn't testable. Apple's sample code, e.g. apple/Scrumdinger, is written using MVC architecture, but there is no test suite. It is unclear whether apple uses some private testing APIs, or just prefers other kinds of tests.

A minimal, Apple-like MVC approach integrates well with existing SwiftUI tooling (not only `@State`, `@Binding`, `@Bindable`, `@Observable`, but also `@Environment` for dependency injection, SwiftData's `@Query`, or even Firebase's `@FirestoreQuery` or Realm's `@ObservedRealmObject`). This often makes it the default choice for many startups (including most of my consulting clients), over more elaborate architectures like pointfree.co's ~~"Modern SwiftUI approach"~~ super clean MVVM, or (also pointfree.co's) The Composable Architecture.

This repository shows that it is possible to achieve decent testing ergonomics using a plain SwiftUI MVC architecture, by adding a reasonable amount of simple boilerplate. It relies on SwiftUI's built-in PreferenceKey mechanism to publish direct access to "controller" Views.

It is imho also a decent showcase of how to use SwiftData for a basic app.
