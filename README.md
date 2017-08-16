# HybridDemo
A hybrid project for iOS, Vue and React.

[![](https://raw.githubusercontent.com/DianQK/HybridDemo/master/screenshot.png)](https://vimeo.com/229822870)

https://vimeo.com/229822870


### 选择图片

#### iOS

```swift
struct SelectImagePlugin: CallBackHybridPlugin {

    static var name: String {
        return "selectImage"
    }

    static func didReceive(message: JSON, webView: WKWebView, viewController: UIViewController) -> Observable<JSON> {
        return Observable<UIImagePickerControllerSourceType>
            .create { (observer) -> Disposable in
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: { _ in
                    observer.onNext(UIImagePickerControllerSourceType.camera)
                    observer.onCompleted()
                }))
                alert.addAction(UIAlertAction(title: "从相册选择", style: .default, handler: { _ in
                    observer.onNext(UIImagePickerControllerSourceType.photoLibrary)
                    observer.onCompleted()
                }))
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                viewController.present(alert, animated: true, completion: nil)
                return Disposables.create {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            .flatMap { sourceType in
                UIImagePickerController.rx.createWithParent(viewController) { picker in
                    picker.sourceType = sourceType
                    picker.allowsEditing = true
                }
            }
            .flatMap { $0.rx.didFinishPickingMediaWithInfo }
            .take(1)
            .map { return $0[UIImagePickerControllerEditedImage] as! UIImage }
            .map { UIImagePNGRepresentation($0)!.base64EncodedString() }
            .map { return JSON(["image": "data:img/jpg;base64," + $0]) }
    }

}
```

#### JavaScript

```js
let response = window.$native.event('selectImage')
this.selectedImage = response.image
```

### 修改标题

#### iOS

```swift
struct TitlePlugin: HybridPlugin {

    static var name: String {
        return "title"
    }

    static func didReceive(message: Observable<(message: JSON, webView: WKWebView, viewController: UIViewController)>) -> Disposable {
        return message
            .subscribe(onNext: { (message, webView, viewController) in
                let title = message["title"].string
                viewController.title = title
            })
    }

}
```

#### Vue & React

```jsx
<NativeTitle title="Hello" />
```

### 图片放大

#### iOS

```swift
struct DisplayImagePlugin: CallBackHybridPlugin {

    static var name: String {
        return "displayImage"
    }

    static func didReceive(message: JSON, webView: WKWebView, viewController: UIViewController) -> Observable<JSON> {
        guard let image = URL(string: message["image"].stringValue).flatMap({ try? Data(contentsOf: $0) }).flatMap({ UIImage(data: $0) }) else {
            return Observable.just(JSON([:]))
        }
        let frame = CGRect(
            x: message["x"].doubleValue,
            y: message["y"].doubleValue + Double(webView.frame.origin.y) - Double(webView.scrollView.contentOffset.y),
            width: message["width"].doubleValue,
            height: message["height"].doubleValue
        )
        let keyWindow = UIApplication.shared.keyWindow!
        let displayView = DisplayView(frame: keyWindow.bounds)
        displayView.display(image: image, frame: frame)
        return displayView.displayFinished.ifEmpty(default: ()).map { JSON([:]) }
    }
}
```

#### Vue

```Vue
<ImageX :src="selectedImage" style="width: 200px; margin-top: 20px;" fullScreen/>
```

#### React

```jsx
<Image src={this.state.selectedImage} width="200" fullScreen />
```

### 右上角按钮点击

#### iOS

```swift
struct RightBarTitlePlugin: HybridPlugin {

    static var name: String {
        return "rightBarTitle"
    }

    static func didReceive(message: Observable<(message: JSON, webView: WKWebView, viewController: UIViewController)>) -> Disposable {
        return message
            .flatMapLatest { (message, webView, viewController) -> Observable<WKWebView> in
                let title = message["title"].stringValue
                if title.isEmpty {
                    viewController.navigationItem.rightBarButtonItem = nil
                    return Observable.empty()
                }
                let rightBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                viewController.navigationItem.rightBarButtonItem = rightBarButtonItem
                return rightBarButtonItem.rx.tap
                    .map { webView }
            }
            .subscribe(onNext: { (webView) in
                webView.evaluateJavaScript("window.$native.rightBarClick();", completionHandler: nil)
            })
    }

}
```

#### Vue

```Vue
<NativeRightBar :title="rightBarTitle" @click="rightBarClick" />
```

#### React

```jsx
<NativeRightBar title={this.state.rightBarTitle} onClick={this.handleClick}/>
```

## TODO

- [ ] Support Web
- [ ] Input Image Component
- [ ] Support Android
