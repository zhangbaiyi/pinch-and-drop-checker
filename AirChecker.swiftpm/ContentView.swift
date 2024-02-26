import SwiftUI

struct ContentView: View {
    
    var body: some View {
            GeometryReader { geo in
                CameraViewWrapper()
            }
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


