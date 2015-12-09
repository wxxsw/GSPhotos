# GSPhotos

// ...

## Example

获取所有相册：
```swift
GSPhotoLibrary.sharedInstance.fetchAlbums { albums, error in
    // do something ...
}
```

获取所有资源：
```swift
GSPhotoLibrary.sharedInstance.fetchAllAssets(.Image) { assets, error in
    // do something ...
}
```

获取指定相册中的资源：
```swift
GSPhotoLibrary.sharedInstance.fetchAssetsInAlbum(album, mediaType: .Image) { assets, error in
    // do something ...
}
```

UIImageView扩展：
```swift
imageView.setImageWithAsset(asset, size: .Thumbnail)
imageView.setImageWithAsset(asset, size: .Original)
imageView.setImageWithAlbum(album)
```

## Parameter

// ...

## License

GSPhotos is available under the MIT license. See the LICENSE file for more info.
