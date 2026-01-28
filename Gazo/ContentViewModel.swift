import SwiftUI
import PhotosUI
import Photos

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
    
    func compressImages(quality:Double) -> [ Data ]{
        var compressedData: [Data] = []
        
        for image in selectedImages {
            if let data = image.jpegData(compressionQuality: quality){
                compressedData.append(data)
            }
        }
        
        return compressedData
    }
    
    func saveCompressedImages(){
        let compressedData = compressImages(quality: compressionQuality)
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges{
                for data in compressedData {
                    PHAssetCreationRequest.creationRequestForAsset(from: UIImage(data: data)!)
                }
            } completionHandler: { success, error in
                if success {
                    print("保存成功しました")
                } else{
                    print("保存失敗しました")
                }
            }
        }
        
    }
}
