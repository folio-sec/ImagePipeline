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

## Supported content types

- ✅ PNG
- ✅ JPEG 
- ✅ GIF
- ✅ WebP
