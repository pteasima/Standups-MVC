import SwiftUI
import SwiftData

enum APreference: PreferenceKey {
    static var defaultValue = 0
    static func reduce(value: inout Int, nextValue: () -> Int) {
        value += nextValue()
    }
}
@Model
final class AModel {
    var number: Int
    
    init(number: Int) {
        self.number = number
    }
}

struct Playground: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var numbers: [AModel] = []
    var body: some View {
        NavigationStack {
            List {
                ForEach(numbers) { number in
                    Text(String(describing: number.number))
                        .preference(key: APreference.self, value: number.number)
                        .transformPreference(APreference.self) {
                            $0 += 1
                        }
                }
            }
            .task {
                let models = (0...100).map(AModel.init)
                models.forEach(modelContext.insert)
            }
        }
        .onPreferenceChange(APreference.self) {
            print($0)
        }
    }
}

#Preview {
    Playground()
}
