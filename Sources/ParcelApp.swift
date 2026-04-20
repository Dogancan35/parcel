import SwiftUI
import SwiftData

@main
struct ParcelApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Package.self])
    }
}
