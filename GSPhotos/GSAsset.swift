//
//  GSAsset.swift
//  GSPhotosExample
//
//  Created by Gesen on 15/10/20.
//  Copyright © 2015年 Gesen. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos
import CoreLocation

/**
 资源类型
 
 - Unknown: 未知
 - Image:   图片
 - Video:   视频
 - Audio:   音频
 */
public enum GSAssetMediaType : Int {
    
    case Unknown = 0
    case Image   = 1
    case Video   = 2
    case Audio   = 3
}

/**
 图片大小
 
 - Thumbnail: 缩略图
 - Original:  原图
 */
public enum GSPhotoImageSize {
    
    case Thumbnail
    case Original
}

public class GSAsset {
    
    // 原始的 PHAsset 或者 ALAsset 实例
    private(set) var originalAsset: AnyObject
    
    // localIdentifier 或者 representationUTI 标识
    private(set) var uniqueIdentifier: String?
    
    // 资源类型，比如图片、视频等
    private(set) var mediaType: GSAssetMediaType!
    
    // 资源子类型, 识别特殊的资源类型，比如全景照片、高频率照片等 (ios8+ only)
//    private(set) var mediaSubtypes: PHAssetMediaSubtype?
    
    // 图片或视频资源的宽度，单位为像素
    private(set) var pixelWidth: Int!
    
    // 图片或视频资源的高度，单位为像素
    private(set) var pixelHeight: Int!
    
    // 资源的原始创建时间
    private(set) var creationDate: NSDate!
    
    // 资源最后被修改的时间 (ios8+ only)
    private(set) var modificationDate: NSDate?
    
    // 资源的位置信息
    private(set) var location: CLLocation?
    
    // 视频资源的时长，单位为秒
    private(set) var duration: NSTimeInterval?
    
    // 同一个Burst序列的唯一标识 (ios8+ only)
    private(set) var burstIdentifier: String?
    
    // 如何被标记为喜欢的Burst序列的类型 (ios8+ only)
//    private(set) var burstSelectionTypes: PHAssetBurstSelectionType?
    
    // 是否在Burst序列中 (ios8+ only)
//    private(set) var representsBurst: Bool?
    
    // MARK: Initialization
    
    @available(iOS 8.0, *)
    init(phAsset: PHAsset) {
        originalAsset = phAsset
        uniqueIdentifier = phAsset.localIdentifier
        mediaType = GSAssetMediaType(rawValue: phAsset.mediaType.rawValue)
//        mediaSubtypes = phAsset.mediaSubtypes
        pixelWidth = phAsset.pixelWidth
        pixelHeight = phAsset.pixelHeight
        creationDate = phAsset.creationDate
        modificationDate = phAsset.modificationDate
        location = phAsset.location
        duration = phAsset.duration
        burstIdentifier = phAsset.burstIdentifier
//        burstSelectionTypes = phAsset.burstSelectionTypes
//        representsBurst = phAsset.representsBurst
    }
    
    init(alAsset: ALAsset) {
        originalAsset = alAsset
        uniqueIdentifier = alAsset.defaultRepresentation().UTI()
        mediaType = mediaTypeForALAsset(alAsset)
        pixelWidth = alAsset.defaultRepresentation().metadata()["PixelWidth"] as! Int
        pixelHeight = alAsset.defaultRepresentation().metadata()["PixelHeight"] as! Int
        creationDate = alAsset.valueForProperty(ALAssetPropertyDate) as! NSDate
        location = alAsset.valueForProperty(ALAssetPropertyLocation) as? CLLocation
        duration = alAsset.valueForProperty(ALAssetPropertyDuration) as? NSTimeInterval
    }
    
    // MARK: Public Method
    
    /**
    获取缩略图
    
    - parameter handler: 完成回调
    
    - returns: 图片请求ID
    */
    public func getThumbnailImage(handler: (UIImage) -> Void) -> GSImageRequestID {
        return getImage(.Thumbnail, handler)
    }
    
    /**
     获取原图
     
     - parameter handler: 完成回调
     
     - returns: 图片请求ID
     */
    public func getOriginalImage(handler: (UIImage) -> Void) -> GSImageRequestID {
        return getImage(.Original, handler)
    }
    
    /**
     获取图片
     
     - parameter size:    大小
     - parameter handler: 完成回调
     
     - returns: 图片请求ID，仅为iOS8+取消图片请求时使用
     */
    public func getImage(size: GSPhotoImageSize, _ handler: (UIImage) -> Void) -> GSImageRequestID {
        
        if #available(iOS 8.0, *) {
            
            let options = PHImageRequestOptions()
            var targetSize: CGSize
            var contentMode: PHImageContentMode
            
            switch size {
            case .Thumbnail:
                options.deliveryMode = .HighQualityFormat
                options.resizeMode = .Fast
                targetSize = CGSize(width: 150, height: 150)
                contentMode = .AspectFill
            case .Original:
                options.deliveryMode = .HighQualityFormat
                targetSize = PHImageManagerMaximumSize
                contentMode = .AspectFit
            }
            
            return PHImageManager.defaultManager().requestImageForAsset(phAsset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: { (image, _) in
                gs_dispatch_main_async_safe {
                    handler(image!)
                }
            })
            
        } else {
            
            var image: UIImage
            
            switch size {
            case .Thumbnail:
                image = UIImage(CGImage: alAsset.thumbnail().takeUnretainedValue())
            case .Original:
                image = UIImage(CGImage: alAsset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
            }
            
            gs_dispatch_main_async_safe {
                handler(image)
            }
            return 0
            
        }
    }
    
    // MARK: Private Method
    
    @available(iOS 8.0, *)
    private var phAsset: PHAsset {
        return originalAsset as! PHAsset
    }
    
    private var alAsset: ALAsset {
        return originalAsset as! ALAsset
    }
    
    /**
     转换ALAssetPropertyType为GSAssetMediaType
     */
    private func mediaTypeForALAsset(alAsset: ALAsset) -> GSAssetMediaType {
        let mediaType: AnyObject! = alAsset.valueForProperty(ALAssetPropertyType)
        if mediaType.isEqualToString(ALAssetTypePhoto) {
            return GSAssetMediaType.Image
        } else if mediaType.isEqualToString(ALAssetTypeVideo) {
            return GSAssetMediaType.Video
        } else {
            return GSAssetMediaType.Unknown
        }
    }
    
}

public typealias GSImageRequestID = Int32