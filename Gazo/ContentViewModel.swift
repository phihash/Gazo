import SwiftUI
import PhotosUI

@Observable
@MainActor
class ContentViewModel {
    var selectedItems: [PhotosPickerItem] = []
    var selectedImages: [UIImage] = []
    
    func loadImages() async {
        selectedItems.removeAll()
        for items in selectedItems {
            do{
                if let data = try await items.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                    selectedImages.append(uiImage)
                }
            } catch {
                
            }
        }
    }
}
