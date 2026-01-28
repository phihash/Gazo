import SwiftUI
import PhotosUI

@Observable
@MainActor
class ContentViewModel {
    var selectedItems: [PhotosPickerItem] = []
    var selectedImages: [UIImage] = []
    var compressionQuality: Double = 0.7
    
    func loadImages() async {
        //画像を読み込んでいたら消す。
        selectedImages.removeAll()
        for items in selectedItems {
            do{
                if let data = try await items.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                    selectedImages.append(uiImage)
                }
            } catch {
                
            }
        }
    }
    
    func compressImages(quality:CGFloat) -> [ Data ]{
        var compressedData: [Data] = []
        
        for image in selectedImages {
            if let data = image.jpegData(compressionQuality: quality){
                compressedData.append(data)
            }
        }
        
        return compressedData
    }
}
