import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    var body: some View {
        VStack {
            PhotosPicker("画像を選ぶ", selection: $viewModel.selectedItems, maxSelectionCount: 5,matching: .images)

        }
        .padding()
    }

}
