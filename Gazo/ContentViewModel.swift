import SwiftUI
import PhotosUI
import Photos

@Observable
@MainActor
class ContentViewModel {
    var pickerItems: [PhotosPickerItem] = []
    var selectedImages: [UIImage] = []
    var compressionQuality: Double = 0.7
    
    func loadImages() async {
        //画像を読み込んでいたら消す。
        selectedImages.removeAll()
        for items in pickerItems {
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
    
    private func saveImageToLibrary(_ compressedData: [Data]) {
        PHPhotoLibrary.shared().performChanges {
            for data in compressedData {
                PHAssetCreationRequest.creationRequestForAsset(from: UIImage(data: data)!)
            }
        } completionHandler: { success, error  in
            if success {
                print("保存成功")
            } else{
                print("保存失敗しました: \(error?.localizedDescription ?? "")")       
            }
        }
    }
    
    func saveCompressedImages(){
        let compressedData = compressImages(quality: compressionQuality)
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized:
            print("許可")
        case .notDetermined:
            print("まだ")
        case .limited:
            print("一部のみ許可")
        case .restricted:
        case .denied:
            print("制限されてる")
            
        @unknown default:
            print("不明な状態")
        }
    }
}
