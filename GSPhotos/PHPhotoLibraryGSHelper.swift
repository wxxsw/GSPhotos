//
//  PHPhotoLibraryGSHelper.swift
//  GSPhotosExample
//
//  Created by Gesen on 15/10/21.
//  Copyright (c) 2015年 Gesen. All rights reserved.
//

import Foundation
import Photos

let PHPhotoLibraryErrorDomain = "PHPhotoLibraryErrorDomain"

@available(iOS 8.0, *)
class PHPhotoLibraryGSHelper {
    
    /// 共享api实例
    let library = PHPhotoLibrary.sharedPhotoLibrary()
    
    // MARK: - For GSPhotoLibrary
    
    /** 获取全部资源集合 */
    func fetchAllAssets(mediaType: GSAssetMediaType, handler: AssetsCompletionHandler) {
        PHPhotoLibraryGSHelper.requestAuthorization { status, error in
            guard error == nil else { handler(nil, error) ; return }
            
            let mediaType = PHAssetMediaType(rawValue: mediaType.rawValue)!
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let fetchAssets = PHAsset.fetchAssetsWithMediaType(mediaType, options: options)
            handler(fetchAssets.convertToGSAssets(), nil)
        }
    }
    
    /** 获取指定相册中的资源 */
    func fetchAssetsInAlbum(album: GSAlbum, mediaType: GSAssetMediaType, handler: AssetsCompletionHandler) {
        PHPhotoLibraryGSHelper.requestAuthorization { status, error in
            guard error == nil else { handler(nil, error) ; return }
            
            let assetCollection = album.originalAssetCollection as! PHAssetCollection
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType = %d", mediaType.rawValue)
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let fetchAssets = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: options)
            handler(fetchAssets.convertToGSAssets(), nil)
        }
    }
    
    /** 获取相册集合 */
    func fetchAlbums(handler: AlbumsCompletionHandler) {
        PHPhotoLibraryGSHelper.requestAuthorization { status, error in
            guard error == nil else { handler(nil, error) ; return }
            
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "estimatedAssetCount > 0")
            
            let fetchSmartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: nil)
            let fetchAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: options)
            
            handler(fetchSmartAlbums.convertToGSAlbums() + fetchAlbums.convertToGSAlbums(), nil)
        }
    }
    
}

// MARK: - Class Method
@available(iOS 8.0, *)
extension PHPhotoLibraryGSHelper {
    
    /**
     请求访问权限
     
     - parameter handler: 完成回调
     */
    class func requestAuthorization(handler: (GSPhotoAuthorizationStatus, error: NSError?) -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            let status = GSPhotoAuthorizationStatus(rawValue: status.rawValue)!
            var error: NSError?
            if status != .Authorized {
                error = NSError(domain: PHPhotoLibraryErrorDomain, code: 403, userInfo: nil)
            }
            handler(status, error: error)
        }
    }
    
    /**
     获取当前访问权限
     
     - returns: 权限状态
     */
    class func authorizationStatus() -> GSPhotoAuthorizationStatus {
        return GSPhotoAuthorizationStatus(rawValue: PHPhotoLibrary.authorizationStatus().rawValue)!
    }
    
}

// MARK: - Convert Extension
@available(iOS 8.0, *)
extension PHFetchResult {
    
    private func convertToGSAssets() -> [GSAsset] {
        var assets = [GSAsset]()
        
        enumerateObjectsUsingBlock { (phAsset, index, stop) in
            if let phAsset = phAsset as? PHAsset {
                assets.append(GSAsset(phAsset: phAsset))
            }
        }
        
        return assets
    }
    
    private func convertToGSAlbums() -> [GSAlbum] {
        var albums = [GSAlbum]()
        
        enumerateObjectsUsingBlock { (phAssetCollection, index, stop) in
            if let phAssetCollection = phAssetCollection as? PHAssetCollection {
                albums.append(GSAlbum(phAssetCollection: phAssetCollection))
            }
        }
        
        return albums
    }
    
}