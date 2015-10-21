//
//  GSAsset.swift
//  
//
//  Created by Gesen on 15/10/20.
//
//

import UIKit
import AssetsLibrary
import Photos
import CoreLocation

public enum GSAssetMediaType : Int {
    
    case Unknown
    case Image
    case Video
    case Audio
}

public enum GSPhotoImageSize {
    
    case Thumbnail
    case Original
}

public class GSAsset {
    
    // Original PHAsset or ALAsset instance.
    private(set) var originalAsset: AnyObject
    
    // localIdentifier or representationUTI
    private(set) var uniqueIdentifier: String?
    
    // The type of the asset, such as video or audio.
    private(set) var mediaType: GSAssetMediaType!
    
    // The subtypes of the asset, identifying special kinds of assets such as panoramic photo or high-framerate video. (PHAsset-only)
    private(set) var mediaSubtypes: PHAssetMediaSubtype?
    
    // The width, in pixels, of the asset’s image or video data.
    private(set) var pixelWidth: Int!
    
    // The height, in pixels, of the asset’s image or video data.
    private(set) var pixelHeight: Int!
    
    // The date and time at which the asset was originally created.
    private(set) var creationDate: NSDate!
    
    // The date and time at which the asset was last modified. (ios8+ only)
    private(set) var modificationDate: NSDate?
    
    // The location information saved with the asset.
    private(set) var location: CLLocation?
    
    // The duration, in seconds, of the video asset.
    private(set) var duration: NSTimeInterval?
    
    // The unique identifier shared by photo assets from the same burst sequence. (ios8+ only)
    private(set) var burstIdentifier: String?
    
    // The unique identifier shared by photo assets from the same burst sequence. (ios8+ only)
    private(set) var burstSelectionTypes: PHAssetBurstSelectionType?
    
    // A Boolean value that indicates whether the asset is the representative photo from a burst photo sequence. (ios8+ only)
    private(set) var representsBurst: Bool?
    
    // MARK: Initialization
    
    init(phAsset: PHAsset) {
        originalAsset = phAsset
        uniqueIdentifier = phAsset.localIdentifier
        mediaType = GSAssetMediaType(rawValue: phAsset.mediaType.rawValue)
        mediaSubtypes = phAsset.mediaSubtypes
        pixelWidth = phAsset.pixelWidth
        pixelHeight = phAsset.pixelHeight
        creationDate = phAsset.creationDate
        modificationDate = phAsset.modificationDate
        location = phAsset.location
        duration = phAsset.duration
        burstIdentifier = phAsset.burstIdentifier
        burstSelectionTypes = phAsset.burstSelectionTypes
        representsBurst = phAsset.representsBurst
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
    
    public func getThumbnailImage(handler: (UIImage) -> Void) -> PHImageRequestID {
        return getImage(.Thumbnail, handler)
    }
    
    public func getOriginalImage(handler: (UIImage) -> Void) -> PHImageRequestID {
        return getImage(.Original, handler)
    }
    
    public func getImage(size: GSPhotoImageSize, _ handler: (UIImage) -> Void) -> PHImageRequestID {
        if GSCanUsePhotoKit {
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
                    handler(image)
                }
            })
        } else {
            var image: UIImage
            
            switch size {
            case .Thumbnail:
                image = UIImage(CGImage: alAsset.thumbnail().takeUnretainedValue())!
            case .Original:
                image = UIImage(CGImage: alAsset.defaultRepresentation().fullScreenImage().takeUnretainedValue())!
            }
            
            gs_dispatch_main_async_safe {
                handler(image)
            }
            return 0
        }
    }
    
    // MARK: Private Method
    
    private var phAsset: PHAsset {
        return originalAsset as! PHAsset
    }
    
    private var alAsset: ALAsset {
        return originalAsset as! ALAsset
    }
    
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