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
    
    /**
     设置资源图片
     
     - parameter asset: 资源实例
     - parameter size:  大小类型
     */
    public func setImageWithAsset(asset: GSAsset, size: GSPhotoImageSize) {
        setImageWithAsset(asset, size: size, placeHolderImage: nil)
    }
    
    /**
     设置资源图片
     
     - parameter asset:            资源实例
     - parameter size:             大小类型
     - parameter placeHolderImage: 占位图片
     */
    public func setImageWithAsset(asset: GSAsset, size: GSPhotoImageSize, placeHolderImage: UIImage?) {
        cancelPHImageRequest()
        self.image = placeHolderImage
        gsImageRequestID = asset.getImage(size) { [weak self] image in
            self?.gsImageRequestID = 0
            self?.image = image
        }
    }
    
    /**
     设置相册图片
     
     - parameter album: 相册实例
     */
    public func setImageWithAlbum(album: GSAlbum) {
        setImageWithAlbum(album, placeHolderImage: nil)
    }
    
    /**
     设置相册图片
     
     - parameter album:            相册实例
     - parameter placeHolderImage: 占位图片
     */
    public func setImageWithAlbum(album: GSAlbum, placeHolderImage: UIImage?) {
        cancelPHImageRequest()
        self.image = placeHolderImage
        gsImageRequestID = album.getPosterImage { [weak self] image in
            self?.gsImageRequestID = 0
            self?.image = image
        }
    }
    
    /**
     取消加载图片（iOS8+ 生效）
     */
    public func cancelPHImageRequest() {
        if gsImageRequestID > 0 {
            if #available(iOS 8.0, *) {
                PHImageManager.defaultManager().cancelImageRequest(gsImageRequestID)
            }
        }
    }
    
    /// 取消加载图片的ID
    private var gsImageRequestID: GSImageRequestID {
        get { return GSImageRequestID((objc_getAssociatedObject(self, &gsImageRequestIDKey) as? Int ?? 0)) }
        set { objc_setAssociatedObject(self, &gsImageRequestIDKey, Int(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
}

private var gsImageRequestIDKey = ""