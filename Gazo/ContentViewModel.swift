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
    
    private func requestPermissionAndSave(_ compressedData:[Data]){
        PHPhotoLibrary.requestAuthorization(for: .addOnly){ status  in
            if status == .authorized || status == .limited {
                Task{ @MainActor in
                    self.saveImageToLibrary(compressedData)
                }
            } else{
                print("許可が得られませんでした")
            }
        }
    }
    
    func saveCompressedImages(){
        let compressedData = compressImages(quality: compressionQuality)
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            saveImageToLibrary(compressedData)
        case .notDetermined:
            requestPermissionAndSave(compressedData)
        case .restricted, .denied:
            print("保存できません。設定から許可してください。")   
        @unknown default:
            print("保存できません。設定から許可してください。")
        }
    }
}
