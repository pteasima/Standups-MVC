import SwiftUI

// Apple docs recommend to use `.alert(,isPresented:,presenting:,actions:message:)` method, where both isPresented must be true and presenting must be non-nil for the alert to be shown.
// Until someone can explain why I would want that, Im assuming this was made by a rogue SwiftUI engineer, and am instead mirroring the other modal presentation APIs like .sheet

extension View {
  func alert<Item, Actions: View, Message: View>(_ titleKey: LocalizedStringKey, item: Binding<Item?>, @ViewBuilder actions: (Item) -> Actions, @ViewBuilder message: (Item) -> Message) -> some View {
    alert(
      titleKey,
      isPresented: Binding {
        item.wrappedValue != nil
      } set: {
        if !$0 {
          item.wrappedValue = nil
        }
      },
      presenting: item.wrappedValue,
      actions: actions,
      message: message
    )
  }
}
