import Foundation
import SwiftUI

enum Theme: String, CaseIterable, Equatable, Hashable, Identifiable, Codable {
  case bubblegum
  case buttercup
  case customIndigo
  case lavender
  case customMagenta
  case navy
  case customOrange
  case oxblood
  case periwinkle
  case poppy
  case customPurple
  case seafoam
  case sky
  case tan
  case customTeal
  case customYellow

  var id: Self { self }

  var accentColor: Color {
    switch self {
    case .bubblegum, .buttercup, .lavender, .customOrange, .periwinkle, .poppy, .seafoam, .sky, .tan,
      .customTeal, .customYellow:
      return .black
    case .customIndigo, .customMagenta, .navy, .oxblood, .customPurple:
      return .white
    }
  }

  var mainColor: Color { Color(self.rawValue) }

  var name: String {
    // I hate this string manipulation with a passion, but it was the fastest way.
    self.rawValue.replacingOccurrences(of: "custom", with: "").capitalized
  }
}

#Preview {
  ScrollView {
    LazyVGrid(
      columns: (0...2).map { _ in GridItem(.flexible(), spacing: 20) },
      spacing: 20
    ) {
      ForEach(Theme.allCases) { theme in
        RoundedRectangle(cornerRadius: 16).fill(theme.mainColor.gradient).aspectRatio(1, contentMode: .fill)
      }
    }
  }
}
