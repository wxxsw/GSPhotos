//
//  GSPhotoLibrary.swift
//  GSPhotosExample
//
//  Created by Gesen on 15/10/20.
//  Copyright © 2015年 Gesen. All rights reserved.
//

import UIKit

public enum GSPhotoAuthorizationStatus: Int {
    
    case NotDetermined // User has not yet made a choice with regards to this application
    case Restricted // This application is not authorized to access photo data.
    // The user cannot change this application’s status, possibly due to active restrictions
    //  such as parental controls being in place.
    case Denied // User has explicitly denied this application access to photos data.
    case Authorized // User has authorized this application to access photos data.
}

public typealias AssetsCompletionHandler = ([GSAsset]?, NSError?) -> Void
public typealias AlbumsCompletionHandler = ([GSAlbum]?, NSError?) -> Void

public class GSPhotoLibrary {
    
    // MARK: Properties
    
    static let sharedInstance = GSPhotoLibrary()
    
    // MARK: Functions
    
    /**
     获取当前访问权限
    
     - returns: 权限状态
    */
    class func authorizationStatus() -> GSPhotoAuthorizationStatus {
        if #available(iOS 8.0, *) {
            return PHPhotoLibraryGSHelper.authorizationStatus()
        } else {
            return ALAssetsLibraryGSHelper.authorizationStatus()
        }
    }
    
    /**
     获取全部资源集合
     
     - parameter mediaType: 资源类型
     - parameter handler:   完成回调
     */
    public func fetchAllAssets(mediaType: GSAssetMediaType, handler: AssetsCompletionHandler) {
        gs_dispatch_async {
            if #available(iOS 8.0, *) {
                self.phLibraryHelper.fetchAllAssets(mediaType, handler: self.safe_assets_handler(handler))
            } else {
                self.alLibraryHelper.fetchAllAssets(mediaType, handler: self.safe_assets_handler(handler))
            }
        }
    }
    
    /**
     获取指定相册中的资源
     
     - parameter album:     相册实例
     - parameter mediaType: 资源类型
     - parameter handler:   完成回调
     */
    public func fetchAssetsInAlbum(album: GSAlbum, mediaType: GSAssetMediaType, handler: AssetsCompletionHandler) {
        gs_dispatch_async {
            if #available(iOS 8.0, *) {
                self.phLibraryHelper.fetchAssetsInAlbum(album, mediaType: mediaType, handler: self.safe_assets_handler(handler))
            } else {
                self.alLibraryHelper.fetchAssetsInAlbum(album, mediaType: mediaType, handler: self.safe_assets_handler(handler))
            }
        }
    }
    
    /**
     获取相册集合
     
     - parameter handler: 完成回调
     */
    public func fetchAlbums(handler: AlbumsCompletionHandler) {
        gs_dispatch_async {
            if #available(iOS 8.0, *) {
                self.phLibraryHelper.fetchAlbums(self.safe_albums_handler(handler))
            } else {
                self.alLibraryHelper.fetchAlbums(self.safe_albums_handler(handler))
            }
        }
    }
    
    // MARK: - Private
    
    @available(iOS 8.0, *)
    private lazy var phLibraryHelper: PHPhotoLibraryGSHelper = {
        return PHPhotoLibraryGSHelper()
    }()
    private lazy var alLibraryHelper: ALAssetsLibraryGSHelper = {
        return ALAssetsLibraryGSHelper()
    }()
    
    private func safe_assets_handler(handler: AssetsCompletionHandler) -> AssetsCompletionHandler {
        return { (assets, error) in
            gs_dispatch_main_async_safe {
                handler(assets, error)
            }
        }
    }
    
    private func safe_albums_handler(handler: AlbumsCompletionHandler) -> AlbumsCompletionHandler {
        return { (albums, error) in
            gs_dispatch_main_async_safe {
                handler(albums, error)
            }
        }
    }
    
}

func gs_dispatch_async(closure: () -> Void) {
    dispatch_async(dispatch_get_global_queue(0, 0)) {
        closure()
    }
}

func gs_dispatch_main_async_safe(closure: () -> Void) {
    if NSThread.isMainThread() {
        closure()
    } else {
        dispatch_async(dispatch_get_main_queue()) {
            closure()
        }
    }
}
