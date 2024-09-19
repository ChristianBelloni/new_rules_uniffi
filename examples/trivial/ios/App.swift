import Trivial
import SwiftUI

@main
struct MyApp: App {
    @State var count: Int = 0

    var body: some Scene {
        WindowGroup {
            VStack {
                Text("Hello world \(count)")
            }.onAppear {
                count = Int(Trivial.add(left: 5, right: 4))
            }
        }
    }
}
