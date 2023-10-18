import SwiftUI
import SwiftData

struct StandupDetailView: View {
    @Bindable var standup: Standup
    @State var isEditing: Bool = false
    var body: some View {
      withChildPreference(key: TextFieldBinding.self) { textFieldPipe in
          Text(standup.title)
            .toolbar {
              ToolbarItem {
                Button {
                  isEditing = true
                } label: {
                  Text("Edit")
                }
              }
            }
            .sheet(isPresented: $isEditing) {
              EditStandupView(standup: standup)
                .syncPreference(using: textFieldPipe)
            }
      }
      .preference(key: ButtonAction.self, value: .init(actions: [ "Edit" : { isEditing = true } ]))
    }
}

#Preview {
    let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
    let standup = Standup.sample
    modelContainer.mainContext.insert(standup)
    return NavigationStack {
        StandupDetailView(standup: standup)
            .modelContainer(modelContainer)
    }
}
