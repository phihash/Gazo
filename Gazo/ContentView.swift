import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    var body: some View {
        VStack {
            PhotosPicker("画像を選ぶ", selection: $viewModel.pickerItems, maxSelectionCount: 30,matching: .images)
                .onChange(of: viewModel.pickerItems){
                    Task{
                        await viewModel.loadImages()
                    }
                }
            
            VStack{
                Text("圧縮率を選んでください")
                Text("現在の圧縮率は\(Int(viewModel.compressionQuality * 100))%")
                Slider(value: $viewModel.compressionQuality, in: 0.1...1.0)
                
                Button("圧縮して保存"){
                    viewModel.saveCompressedImages()
                }.disabled(viewModel.pickerItems.isEmpty)
            }
        }
        .padding()
    }
}
