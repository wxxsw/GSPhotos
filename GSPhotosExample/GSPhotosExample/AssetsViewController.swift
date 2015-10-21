//
//  AssetsViewController.swift
//  
//
//  Created by Gesen on 15/10/21.
//
//

import UIKit

private let reuseIdentifier = "Cell"

class AssetsViewController: UICollectionViewController {
    
    var assets: [GSAsset] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GSPhotoLibrary.sharedInstance.fetchAssets(.Image) { [unowned self] assets, error in
            if let assets = assets where error == nil {
                self.assets = assets
                self.collectionView!.reloadData()
            } else {
                println(GSPhotoLibrary.authorizationStatus())
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

}
