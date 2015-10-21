//
//  UIImageView+GSPhotos.swift
//  GSPhotosExample
//
//  Created by Gesen on 15/10/21.
//  Copyright (c) 2015年 Gesen. All rights reserved.
//

import UIKit
import Photos

extension UIImageView {
    
    public func setImageWithAsset(asset: GSAsset, size: GSPhotoImageSize) {
        setImageWithAsset(asset, size: size, placeHolderImage: nil)
    }
    
    public func setImageWithAsset(asset: GSAsset, size: GSPhotoImageSize, placeHolderImage: UIImage?) {
        cancelPHImageRequest()
        self.image = placeHolderImage
        phImageRequestID = asset.getImage(size) { [weak self] image in
            self?.phImageRequestID = 0
            self?.image = image
        }
    }
    
    public func cancelPHImageRequest() {
        if phImageRequestID > 0 {
            PHImageManager.defaultManager().cancelImageRequest(phImageRequestID)
        }
    }
    
    private var phImageRequestID: PHImageRequestID {
        get { return PHImageRequestID((objc_getAssociatedObject(self, &phImageRequestIDKey) as? Int ?? 0)) }
        set { objc_setAssociatedObject(self, &phImageRequestIDKey, Int(newValue), UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC)) }
    }
    
}

private var phImageRequestIDKey = ""