//
//  ALAssetsLibraryGSHelper.swift
//  GSPhotosExample
//
//  Created by Gesen on 15/10/21.
//  Copyright (c) 2015年 Gesen. All rights reserved.
//

import Foundation
import AssetsLibrary

class ALAssetsLibraryGSHelper {
    
    /// 共享api实例
    let library = ALAssetsLibrary()
    
    /// 分组缓存
    var groups = [ALAssetsGroup]()
    /// 分组获取状态
    var groupsFetchStatus = ALAssetsGroupsFetchStatus.None
    
    /**
     异步获取分组进度
     
     - None:    未开始
     - Loading: 获取中
     - Fetched: 获取完成
     */
    enum ALAssetsGroupsFetchStatus {
        case None
        case Loading
        case Fetched
    }
    
    // MARK: - For GSPhotoLibrary
    
    /** 获取全部资源集合 */
    func fetchAllAssets(mediaType: GSAssetMediaType, handler: AssetsCompletionHandler) {
        fetchGroups { groups, error in
            guard let groups = groups where error == nil else { handler(nil, error) ; return }
            
            var assets = [GSAsset]()
            for group in groups {
                assets += group.convertToGSAssets(mediaType)
            }
            handler(assets, nil)
        }
    }
    
    /** 获取指定相册中的资源 */
    func fetchAssetsInAlbum(album: GSAlbum, mediaType: GSAssetMediaType, handler: AssetsCompletionHandler) {
        guard let group = album.originalAssetCollection as? ALAssetsGroup else {
            handler(nil, NSError(domain: ALAssetsLibraryErrorDomain, code: ALAssetsLibraryDataUnavailableError, userInfo: nil))
            return
        }
        
        handler(group.convertToGSAssets(mediaType), nil)
    }
    
    /** 获取相册集合 */
    func fetchAlbums(handler: AlbumsCompletionHandler) {
        fetchGroups { groups, error in
            guard let groups = groups where error == nil else { handler(nil, error) ; return }
            
            var assetCollections = [GSAlbum]()
            for group in groups {
                assetCollections.append(GSAlbum(alAssetsGroup: group))
            }
            handler(assetCollections, nil)
        }
    }
    
    // MARK: - Private
    
    private let waitLoadingQueue = dispatch_queue_create("wait_loading_queue", DISPATCH_QUEUE_CONCURRENT)
    
    /**
     获取所有相册的ALAssetsGroup集合
     .None：状态转为Loading，获取数据成功后转为Fetched，失败返回None
     .Loading：进入等待队列，每1秒检查一次状态改变
     .Fetched：直接返回结果
     
     - parameter handler: 完成回调
     */
    private func fetchGroups(handler: ([ALAssetsGroup]?, NSError?) -> Void) {
        switch groupsFetchStatus {
        case .None:

            library.enumerateGroupsWithTypes(ALAssetsGroupAll,
                usingBlock: { [unowned self] (group, _) in
                    if group != nil {
                        if group.numberOfAssets() > 0 {
                            self.groups.insert(group, atIndex: 0)
                        }
                    } else {
                        handler(self.groups, nil)
                        self.groupsFetchStatus = .Fetched
                    }
                },
                failureBlock: { error in
                    handler(nil, error)
                    self.groupsFetchStatus = .None
                }
            )
            groupsFetchStatus = .Loading
            
        case .Loading:
            
            dispatch_async(waitLoadingQueue) {
                while self.groupsFetchStatus != .Loading {
                    NSThread.sleepForTimeInterval(1)
                }
                if self.groupsFetchStatus == .None {
                    handler(nil, NSError(domain: ALAssetsLibraryErrorDomain, code: ALAssetsLibraryUnknownError, userInfo: nil))
                }
                if self.groupsFetchStatus == .Fetched {
                    handler(self.groups, nil)
                }
            }
            
        case .Fetched:
            
            handler(self.groups, nil)
            
        }
    }
    
}

// MARK: - Class Method
extension ALAssetsLibraryGSHelper {
    
    /**
     获取当前访问权限
     
     - returns: 权限状态
     */
    class func authorizationStatus() -> GSPhotoAuthorizationStatus {
        return GSPhotoAuthorizationStatus(rawValue: ALAssetsLibrary.authorizationStatus().rawValue)!
    }
    
}

// MARK: - Convert Extension
extension ALAssetsGroup {
    
    private func convertToGSAssets(mediaType: GSAssetMediaType) -> [GSAsset] {
        var assets = [GSAsset]()
        
        switch mediaType {
        case .Image: setAssetsFilter(ALAssetsFilter.allPhotos())
        case .Video: setAssetsFilter(ALAssetsFilter.allVideos())
        default: break
        }
        
        enumerateAssetsWithOptions(.Reverse) { (alAsset, index, stop) in
            if alAsset != nil {
                assets.append(GSAsset(alAsset: alAsset))
            }
        }
        
        return assets
    }
    
}