import SwiftUI

struct ContentView: View {
    
    var body: some View {
            GeometryReader { geo in
                CameraViewWrapper()
                    // You can adjust the camera view's properties or modifiers as needed
            }
            // Any additional modifiers to adjust the layout or behavior of the camera view can be added here
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


