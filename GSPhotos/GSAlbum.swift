//
//  GSAlbum.swift
//  GSPhotosExample
//
//  Created by Gesen on 15/10/28.
//  Copyright (c) 2015年 Gesen. All rights reserved.
//

import Foundation
import AssetsLibrary
import Photos
import CoreLocation

public class GSAlbum {
    
    // 原始的 PHAssetCollection 或者 ALAssetsGroup 实例
    private(set) var originalAssetCollection: AnyObject
    
    // 相册名称
    private(set) var name: String
    
    // 包含的资源数量
    private(set) lazy var count: Int = {
        if #available(iOS 8, *) {
            return PHAsset.fetchAssetsInAssetCollection(self.phAssetCollection, options: nil).count
        } else {
            return self.alAssetsGroup.numberOfAssets()
        }
    }()
    
    @available(iOS 8.0, *)
    init(phAssetCollection: PHAssetCollection) {
        self.originalAssetCollection = phAssetCollection
        self.name = phAssetCollection.localizedTitle ?? ""
    }
    
    init(alAssetsGroup: ALAssetsGroup) {
        self.originalAssetCollection = alAssetsGroup
        self.name = alAssetsGroup.valueForProperty(ALAssetsGroupPropertyName) as? String ?? ""
    }
    
    /**
     获取封面图片
     
     - parameter handler: 完成回调
     
     - returns: 图片请求ID，仅为iOS8+取消图片请求时使用
     */
    public func getPosterImage(handler: (UIImage?) -> Void) -> GSImageRequestID {
        
        if let cachePosterImage = cachePosterImage {
            handler(cachePosterImage)
            return 0
        }
        
        if #available(iOS 8, *) {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", GSAssetMediaType.Image.rawValue)
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let fetch = PHAsset.fetchAssetsInAssetCollection(phAssetCollection, options: fetchOptions)
            
            guard let phAsset = fetch.firstObject as? PHAsset else {
                handler(nil)
                return 0
            }
            
            let targetSize = CGSize(width: 150, height: 150)
            let contentMode: PHImageContentMode = .AspectFill
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .HighQualityFormat
            options.resizeMode = .Fast
            
            return PHImageManager.defaultManager().requestImageForAsset(phAsset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: { (image, _) in
                gs_dispatch_main_async_safe {
                    self.cachePosterImage = image
                    handler(image!)
                }
            })
            
        } else {
            
            let image = UIImage(CGImage: self.alAssetsGroup.posterImage().takeUnretainedValue())
            
            gs_dispatch_main_async_safe {
                self.cachePosterImage = image
                handler(image)
            }
            return 0
            
        }
        
    }
    
    // MARK: Private Method
    
    private var cachePosterImage: UIImage?
    
    @available(iOS 8.0, *)
    private var phAssetCollection: PHAssetCollection {
        return originalAssetCollection as! PHAssetCollection
    }
    
    private var alAssetsGroup: ALAssetsGroup {
        return originalAssetCollection as! ALAssetsGroup
    }

}