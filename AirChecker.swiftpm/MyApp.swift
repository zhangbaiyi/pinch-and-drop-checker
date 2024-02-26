import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(){
                    tidyCatalystWindow()
                }
        }
    }
}

func tidyCatalystWindow() {
    #if targetEnvironment(macCatalyst)
    UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
        // Set both the minimum and maximum sizes to the same value to prevent resizing
        let fixedSize = CGSize(width: 800, height: 800)
        windowScene.sizeRestrictions?.minimumSize = fixedSize
        windowScene.sizeRestrictions?.maximumSize = fixedSize
    }
    #endif
}
