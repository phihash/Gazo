import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var fileSizeText: String = "—"
    
    var body: some View {
        VStack {
            Text(fileSizeText)
            PhotosPicker("画像を選ぶ",selection: $selectedItem,matching: .images)
    
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
            } else {
                Text("ここに画像が表示されます")
            }
        }
        .padding()
        .task(id:selectedItem){
            guard let selectedItem else { return }
            do{
                if let data = try await selectedItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    fileSizeText = "\(data.count)B"
                    selectedImage = uiImage
                }
            } catch {
                
            }
 
        }
    }
}
