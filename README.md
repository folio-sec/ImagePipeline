[![Build Status](https://app.bitrise.io/app/d45feb8efa5f59db/status.svg?token=kXMrRSrj4C8sHeWB26tQuw)](https://app.bitrise.io/app/d45feb8efa5f59db)
[![codecov](https://codecov.io/gh/folio-sec/ImagePipeline/branch/master/graph/badge.svg)](https://codecov.io/gh/folio-sec/ImagePipeline)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# ImagePipeline
Folio Image Pipeline is an image loading and caching framework for iOS clients

## Usage


```swift
let imagePipeline = ImagePipeline()
imagePipeline.shared.load(/* image URL */, into: /* image view */, transition: .fadeIn /* default is `.none`*/,
                          defaultImage: ..., failureImage: ...)
```

### Example

```swift
override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell

    ImagePipeline.shared.load(urls[indexPath.row % 200],
                              into: cell.imageView,
                              transition: .fadeIn,
                              defaultImage: UIImage(named: "loading")!,
                              failureImage: UIImage(named: "failed")!)
    
    return cell
}
```

### Resize

#### Aspect Fit (Default)

```swift
let resizer = ImageResizer(targetSize: CGSize(width: 400, height: 400))
ImagePipeline.shared.load(/* imageURL */, into: /* image view */, processors: [resizer])
```

|Original|Resized|
|:-:|:-:|
|![1](https://user-images.githubusercontent.com/40610/50732276-11ff2080-11bb-11e9-863c-bbfa815a9e76.png)|![testimageresizeraspectfit 1](https://user-images.githubusercontent.com/40610/50732270-eaa85380-11ba-11e9-900c-7f5fa9df9334.png)|

#### Aspect Fill

```swift
let resizer = ImageResizer(targetSize: CGSize(width: 400, height: 400), contentMode: .aspectFill)
ImagePipeline.shared.load(/* imageURL */, into: /* image view */, processors: [resizer])
```

|Original|Resized|
|:-:|:-:|
|![1](https://user-images.githubusercontent.com/40610/50732276-11ff2080-11bb-11e9-863c-bbfa815a9e76.png)|![testimageresizeraspectfill 1](https://user-images.githubusercontent.com/40610/50732269-eaa85380-11ba-11e9-9b02-c268e377532b.png)|


### Resize & Blur

```swift
let scale: CGFloat = 2
let size = CGSize(width: 375 * scale, height: 232 * scale)
let resizer = ImageResizer(targetSize: size, contentMode: .aspectFill)
let filter = BlurFilter(style: .light)

ImagePipeline.shared.load(/* imageURL */, into: /* image view */, processors: [resizer, filter])
```

|Original|Blurred|
|:-:|:-:|
|![resize](https://user-images.githubusercontent.com/40610/50732307-a79ab000-11bb-11e9-87c6-0a83a845c076.jpeg)|![testblurfilter 2](https://user-images.githubusercontent.com/40610/50732310-b84b2600-11bb-11e9-9f38-e0f80632e1a4.png)|

## TTL

ImagePipeline respects the [`max-age` value of `Cache-Control` response header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control), and sets independent TTL for each image.

## Supported content types

✅ PNG  
✅ JPEG  
✅ GIF  
✅ WebP 
