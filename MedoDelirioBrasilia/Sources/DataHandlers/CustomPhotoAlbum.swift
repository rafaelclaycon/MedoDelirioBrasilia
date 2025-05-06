//
//  CustomPhotoAlbum.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 20/10/22.
//

import Foundation
import PhotosUI

class CustomPhotoAlbum: NSObject {

    static let albumName = "Medo e Delírio"
    static let shared = CustomPhotoAlbum()
    
    var assetCollection: PHAssetCollection!
    
    override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            self.createAlbum()
        } else {
            print("should really prompt the user to let them know it's failed")
        }
    }
    
    func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
        }) { success, error in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            } else {
                print("error \(String(describing: error))")
            }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(video videoURL: URL) async throws {
//        if assetCollection == nil {
//            return // if there was an error upstream, skip the save
//        }

        try await PHPhotoLibrary.shared().performChanges() {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }

        /*var placeholder: PHObjectPlaceholder
        var identifier: String
        
        PHPhotoLibrary.shared().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(videoURL)
            placeholder = createAssetRequest.placeholderForCreatedAsset
            identifier = placeholder.localIdentifier
        }, completionHandler: { success, error in
            /*
               Fetch Asset with the identifier here
               after that, add the PHAsset into an album
            */
            newAsset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject
            
            PHPhotoLibrary.shared().performChanges({
                let createRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
                placeHolderIdentifier = createRequest.placeholderForCreatedAssetCollection.localIdentifier
            }, completionHandler: {
                success, error in
                if success {
                    var createdCollection: PHAssetCollection? = nil
                    if placeHolderIdentifier != nil {
                        createdCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeHolderIdentifier!], options: nil).firstObject
                    }
                    completion(success, createdCollection as? T)
                } else {
                    LogError("\(error)")
                    completion(success, nil)
                }
            })
            
        }
        
        
        var placeholderIdentifier: String = ""
        
        PHPhotoLibrary.shared().performChanges({
            //PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            let createRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
            placeholderIdentifier = createRequest.placeholderForCreatedAssetCollection.localIdentifier
        }, completionHandler: { success, error in
            if success {
                //var createdCollection: PHAssetCollection? = nil
//                if placeholderIdentifier != nil {
//                    createdCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholderIdentifier!], options: nil).firstObject
//                }
                print(placeholderIdentifier)
                completion(true, nil)
            } else {
                completion(false, error?.localizedDescription)
            }
        })*/
    }

    func save(image: UIImage) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
}
