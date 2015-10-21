# GSPhotos
still in development…


## Example

从相册中获取所有图片资源：
```swift
GSPhotoLibrary.sharedInstance.fetchAssets(.Image) { [unowned self] assets, error in
    if let assets = assets where error == nil {
        self.assets = assets
        self.collectionView!.reloadData()
    } else {
        println(GSPhotoLibrary.authorizationStatus())
    }
}
```

在UIImageView上显示缩略图：
```swift
cell.imageView.setImageWithAsset(assets[indexPath.row], size: .Thumbnail)
```

## License

GSPhotos is available under the MIT license. See the LICENSE file for more info.
