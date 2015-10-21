//
//  PHPhotoLibraryGSHelper.swift
//  GSPhotosExample
//
//  Created by Gesen on 15/10/21.
//  Copyright (c) 2015年 Gesen. All rights reserved.
//

import Foundation
import Photos

class PHPhotoLibraryGSHelper {
    
    let library = PHPhotoLibrary.sharedPhotoLibrary()
    
    func fetchAssets(mediaType: GSAssetMediaType, handler: ([GSAsset]?, NSError?) -> Void) {
        PHPhotoLibraryGSHelper.requestAuthorization { status in
            if status == .Authorized {
                var assets = [GSAsset]()
                let mediaType = PHAssetMediaType(rawValue: mediaType.rawValue)!
                let options = PHFetchOptions()
//                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                PHAsset.fetchAssetsWithMediaType(mediaType, options: options).enumerateObjectsUsingBlock { (phAsset, index, stop) in
                    if let phAsset = phAsset as? PHAsset {
                        assets.append(GSAsset(phAsset: phAsset))
                    }
                }
                handler(assets, nil)
            } else {
                let error = NSError(domain: "PHPhotoLibraryErrorDomain", code: 403, userInfo: nil)
                handler(nil, error)
            }
        }
    }
    
    class func requestAuthorization(handler: (GSPhotoAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            handler(GSPhotoAuthorizationStatus(rawValue: status.rawValue)!)
        }
    }
    
    class func authorizationStatus() -> GSPhotoAuthorizationStatus {
        return GSPhotoAuthorizationStatus(rawValue: PHPhotoLibrary.authorizationStatus().rawValue)!
    }
    
}