# GSPhotos

苹果在iOS8推出了全新的`PhotosKit`框架使应用与设备照片库对接，相比旧的`ALAssetsLibrary`框架更完整更高效，并使用全新的API。但`PhotosKit`最低支持iOS8，如果你仍然需要支持iOS7，你将不得不同时使用两个框架，`GSPhotos`解决了这个问题。

## Key Featrue

* 当运行于iOS8+时自动使用`PhotosKit`，iOS7时自动使用`ALAssetsLibrary`
* 包含常用的资源、相册属性
* 支持获取相册列表、资源列表
* 轻松设置相册封面、资源缩略图、原图

## Example

### 获取列表

相册列表，返回`GSAlbum`数组，如果执行成功`error`值为`nil`
```swift
GSPhotoLibrary.sharedInstance.fetchAlbums { albums, error in
    // do something...
}
```

指定相册下的照片列表，返回`GSAsset`数组，如果执行成功`error`值为`nil`
```swift
GSPhotoLibrary.sharedInstance.fetchAssetsInAlbum(album, mediaType: .Image) { assets, error in
    // do something...
}
```

所有照片的列表，返回`GSAsset`数组，如果执行成功`error`值为`nil`
```swift
GSPhotoLibrary.sharedInstance.fetchAllAssets(.Image) { assets, error in
    // do something...
}
```

### 设置 UIImageView：

* 资源图片
```swift
imageView.setImageWithAsset(asset, size: .Thumbnail)
imageView.setImageWithAsset(asset, size: .Original, placeHolderImage: placeHolderImage)
```

* 相册封面
```swift
imageView.setImageWithAlbum(album)
imageView.setImageWithAlbum(album, placeHolderImage: placeHolderImage)
```

## GSAlbum

#### Properties

原始的 PHAssetCollection 或者 ALAssetsGroup 实例：

	private(set) var originalAssetCollection: AnyObject

相册名称：

    private(set) var name: String
    
包含的资源数量

    private(set) var count: Int
    
#### Functions
    
获取封面图片 UIImage
    
    //
    //  示例
    //  album.getPosterImage { image in
    //      // do something...
    //  }
    //
    func getPosterImage(handler: (UIImage?) -> Void)


## GSAsset

#### Properties

原始的 PHAsset 或者 ALAsset 实例：

    private(set) var originalAsset: AnyObject
    
localIdentifier 或者 representationUTI 唯一标识：

    private(set) var uniqueIdentifier: String?
    
资源类型，比如图片、视频等

    private(set) var mediaType: GSAssetMediaType!
    
图片或视频资源的宽度，单位为像素

    private(set) var pixelWidth: Int!
    
图片或视频资源的高度，单位为像素

    private(set) var pixelHeight: Int!
    
资源的原始创建时间

    private(set) var creationDate: NSDate!
    
资源最后被修改的时间 (ios8+ only)

    private(set) var modificationDate: NSDate?
    
资源的位置信息

    private(set) var location: CLLocation?
    
视频资源的时长，单位为秒

    private(set) var duration: NSTimeInterval?
    
同一个Burst序列的唯一标识 (ios8+ only)

    private(set) var burstIdentifier: String?

#### Functions

获取图片 UIImage

    //
    //  示例
    //  asset.getImage(.Orignal) { image in
    //      // do something...
    //  }
    //
    func getImage(size: GSPhotoImageSize, _ handler: (UIImage) -> Void)
    

## 枚举参数说明

`mediaType`: 资源类型
```swift
public enum GSAssetMediaType : Int {
    
    case Unknown = 0    // 未知
    case Image   = 1    // 图片
    case Video   = 2    // 视频
    case Audio   = 3    // 音频
}
```

`size`: 图片大小
```swift
public enum GSPhotoImageSize {
    
    case Thumbnail      // 缩略图
    case Original       // 原图
}
```

## License

GSPhotos is available under the MIT license. See the LICENSE file for more info.
