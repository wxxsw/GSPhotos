//
//  GSPhotoLibrary.swift
//  
//
//  Created by Gesen on 15/10/20.
//
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

public class GSPhotoLibrary {
    
    // MARK: Properties
    
    static let sharedInstance = GSPhotoLibrary()
    
    // MARK: Functions
    
    class func authorizationStatus() -> GSPhotoAuthorizationStatus {
        if GSCanUsePhotoKit {
            return PHPhotoLibraryGSHelper.authorizationStatus()
        } else {
            return ALAssetsLibraryGSHelper.authorizationStatus()
        }
    }
    
    public func fetchAssets(mediaType: GSAssetMediaType, handler: ([GSAsset]?, NSError?) -> Void) {
        if GSCanUsePhotoKit {
            phLibraryHelper.fetchAssets(mediaType) { (assets, error) in
                gs_dispatch_main_async_safe {
                    handler(assets, error)
                }
            }
        } else {
            alLibraryHelper.fetchAssets(mediaType) { (assets, error) in
                gs_dispatch_main_async_safe {
                    handler(assets, error)
                }
            }
        }
    }
    
    private let libraryHelper: AnyObject = GSCanUsePhotoKit ? PHPhotoLibraryGSHelper() : ALAssetsLibraryGSHelper()
    
    private var phLibraryHelper: PHPhotoLibraryGSHelper {
        return libraryHelper as! PHPhotoLibraryGSHelper
    }
    private var alLibraryHelper: ALAssetsLibraryGSHelper {
        return libraryHelper as! ALAssetsLibraryGSHelper
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

let GSCanUsePhotoKit = NSString(string: UIDevice.currentDevice().systemVersion).floatValue >= 8.0
