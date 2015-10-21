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
    
    class func authorizationStatus() -> GSPhotoAuthorizationStatus {
        return GSPhotoAuthorizationStatus(rawValue: ALAssetsLibrary.authorizationStatus().rawValue)!
    }
    
    let library = ALAssetsLibrary()
    var groups = [ALAssetsGroup]()
    var groupsFetchStatus = ALAssetsGroupsFetchStatus.None
    
    enum ALAssetsGroupsFetchStatus {
        case None
        case Loading
        case Fetched
    }
    
    func fetchAssets(mediaType: GSAssetMediaType, handler: ([GSAsset]?, NSError?) -> Void) {
        fetchALAssetsGroups { (groups, error) in
            if let groups = groups where error == nil {
                var assets = [GSAsset]()
                for group in groups {
                    switch mediaType {
                    case .Image: group.setAssetsFilter(ALAssetsFilter.allPhotos())
                    case .Video: group.setAssetsFilter(ALAssetsFilter.allVideos())
                    default: break
                    }
                    group.enumerateAssetsUsingBlock { (alAsset, index, stop) in
                        if alAsset != nil {
                            assets.append(GSAsset(alAsset: alAsset))
                        }
                    }
                }
                handler(assets, nil)
            } else {
                handler(nil, error)
            }
        }
    }
    
    func fetchALAssetsGroups(handler: ([ALAssetsGroup]?, NSError?) -> Void) {
        switch groupsFetchStatus {
        case .None:
            groupsFetchStatus = .Loading
            library.enumerateGroupsWithTypes(ALAssetsGroupAll,
                usingBlock: { [unowned self] (group, _) in
                    if group != nil {
                        self.groups.append(group)
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
        case .Loading:
            let waitLoadingQueue = dispatch_queue_create("wait_loading_queue", DISPATCH_QUEUE_CONCURRENT)
            dispatch_async(waitLoadingQueue) {
                while self.groupsFetchStatus != .Loading {
                    NSThread.sleepForTimeInterval(1)
                }
                if self.groupsFetchStatus == .None {
                    let error = NSError(domain: ALAssetsLibraryErrorDomain, code: ALAssetsLibraryUnknownError, userInfo: nil)
                    handler(nil, error)
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