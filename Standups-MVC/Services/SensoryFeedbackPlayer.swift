import Foundation
import SwiftUI
import AVFoundation

// inspired by `SwiftUI.View.sensoryFeedback`, but allows more customization.
struct CustomSensoryFeedback {
  //TODO: figure out how to do haptics and maybe get rid of this struct and flatten the api
  var soundFilename: String?
//  var haptic: ?
}

struct SensoryFeedbackPlayer {
  var load: (CustomSensoryFeedback) -> Void
  var play: () -> Void
}
extension SensoryFeedbackPlayer: EnvironmentKey {
  // defaultValue must be stored. If its computed, SwiftUI calls it multiple times and I end up with a different AVPlayer from the time load was called to the time play is called (so nothing plays). TODO: understand this better.
  static var defaultValue: Self = {
    let player = AVPlayer() // pointfreeco use LockIsolated here, but Im sorry, I dont' care if there's a racecondition in unimportant sound feedback. Might improve this in the future...
    return Self(
      load: { model in
        guard let url = Bundle.main.url(forResource: model.soundFilename, withExtension: "")
        else { assertionFailure(); return }
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
      },
      play: {
        player.seek(to: .zero)
        player.play()
      }
    )
  }()
}

extension View {
  func customSensoryFeedback<Trigger: Equatable>(_ feedback: CustomSensoryFeedback, trigger: Trigger) -> some View {
    modifier(CustomSensoryFeedbackViewModifier(feedback: feedback, trigger: trigger))
  }
}

fileprivate struct CustomSensoryFeedbackViewModifier<Trigger: Equatable> : ViewModifier {
  @Environment(SensoryFeedbackPlayer.self) private var player
  var feedback: CustomSensoryFeedback
  var trigger: Trigger
  func body(content: Content) -> some View {
      content
      .task {
        // !!! this might load mutliple times needlessly, also might not reload if player changes in parent environment
        player.load(feedback)
      }
      .onChange(of: trigger) { _,_ in
        player.play()
      }
  }
}


