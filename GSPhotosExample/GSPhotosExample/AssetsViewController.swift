//
//  AssetsViewController.swift
//  GSPhotosExample
//
//  Created by Gesen on 15/10/21.
//  Copyright © 2015年 Gesen. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class AssetsViewController: UICollectionViewController {
    
    var album: GSAlbum?
    var assets: [GSAsset] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupItemSize()
        
        if let album = album {
            
            GSPhotoLibrary.sharedInstance.fetchAssetsInAlbum(album, mediaType: .Image) { assets, error in
                if let assets = assets where error == nil {
                    self.assets = assets
                    self.collectionView?.reloadData()
                } else {
                    print(GSPhotoLibrary.authorizationStatus())
                }
            }
            
        } else {
        
            GSPhotoLibrary.sharedInstance.fetchAllAssets(.Image) { assets, error in
                if let assets = assets where error == nil {
                    self.assets = assets
                    self.collectionView?.reloadData()
                } else {
                    print(GSPhotoLibrary.authorizationStatus())
                }
            }
            
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AssetCell
    
        cell.imageView.setImageWithAsset(assets[indexPath.row], size: .Thumbnail)
    
        return cell
    }
    
    // MARK: Setup Layout
    
    private func setupItemSize() {
        let sideLength = (view.bounds.size.width - 5 * 4) / 3
        (collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: sideLength, height: sideLength)
    }
}
