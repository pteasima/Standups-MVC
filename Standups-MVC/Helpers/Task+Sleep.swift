import Foundation

// sleep for minimum amount of time (next runloop if on MainActor)
extension Task where Success == Never, Failure == Never {
    static func sleep() async throws {
        try await sleep(until: .now, clock: .suspending)
    }
    static func sleep<C: Clock>(clock: C) async throws {
        try await sleep(until: clock.now, clock: clock)
    }
}
