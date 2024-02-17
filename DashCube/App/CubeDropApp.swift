import SwiftUI
import GameKit

@main
struct CubeDropApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    authenticateUser()
                }
        }
    }
    
    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
        }
    }
}
