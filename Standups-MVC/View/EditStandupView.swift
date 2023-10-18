import SwiftUI
import SwiftData

struct EditStandupView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var standup: Standup
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(text: $standup.title) {
                        Text("Title")
                    }
                }
            }
            .navigationTitle(standup.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        //TODO: undo via undo manager
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
        .preference(key: TextFieldBinding.self, value: .init(id: "Title Field", text: $standup.title))
    }
}

#Preview {
    let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
    let standup = Standup.sample
    modelContainer.mainContext.insert(standup)
    return EditStandupView(standup: standup)
        .modelContainer(modelContainer)
}
