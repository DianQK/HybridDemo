//
//  Plugin.swift
//  HybridDemo
//
//  Created by wc on 13/08/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit
import SnapKit
import SwiftyJSON

struct TitlePlugin: HybridPlugin {
    
    static var name: String {
        return "title"
    }
    
    static func didReceive(message: Observable<(message: JSON, webView: WKWebView)>) -> Disposable {
        return message
            .subscribe(onNext: { (message, webView) in
                let title = message["title"].string
                if webView.parentViewController?.title != title {
                    webView.parentViewController?.title = title
                }
            })
    }
    
}

public protocol CallBackHybridPlugin: HybridPlugin {
    
    static func didReceive(message: JSON, webView: WKWebView) -> Observable<JSON>
    
}


extension CallBackHybridPlugin {
    
    public static func didReceive(message: Observable<(message: JSON, webView: WKWebView)>) -> Disposable {
        return message
            .flatMap { (message, webView) -> Observable<(callbackId: String, response: JSON, webView: WKWebView)> in
                let callbackId = message["callbackId"].stringValue
                let content = message["content"]
                return didReceive(message: content, webView: webView)
                    .map { (response) in
                        return (callbackId: callbackId, response: response, webView: webView)
                }
            }
            .subscribe(onNext: { (callbackId, response, webView) in
                webView.evaluateJavaScript("window.$native.callbacks['\(callbackId)'].callback(\(response.rawString() ?? "{}"));", completionHandler: nil)
            })
    }
    
}


struct SelectImagePlugin: CallBackHybridPlugin {
    
    static var name: String {
        return "selectImage"
    }
    
    static func didReceive(message: JSON, webView: WKWebView) -> Observable<JSON> {
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
                webView.parentViewController?.present(alert, animated: true, completion: nil)
                return Disposables.create {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            .flatMap { sourceType in
                UIImagePickerController.rx.createWithParent(webView.parentViewController!) { picker in
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

struct RightBarTitlePlugin: HybridPlugin {
    
    static var name: String {
        return "rightBarTitle"
    }
    
    static func didReceive(message: Observable<(message: JSON, webView: WKWebView)>) -> Disposable {
        return message
            .flatMapLatest { (message, webView) -> Observable<WKWebView> in
                let title = message["title"].stringValue
                if title.isEmpty {
                    webView.parentViewController?.navigationItem.rightBarButtonItem = nil
                    return Observable.empty()
                }
                let bar: UIBarButtonItem
                if let rightBarButtonItem = webView.parentViewController?.navigationItem.rightBarButtonItem {
                    bar = rightBarButtonItem
                    if bar.title != title {
                        webView.parentViewController?.navigationItem.rightBarButtonItem = nil
                        bar.title = title
                        webView.parentViewController?.navigationItem.rightBarButtonItem = bar
                    }
                } else {
                    bar = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                    webView.parentViewController?.navigationItem.rightBarButtonItem = bar
                }
                return bar.rx.tap.map { webView }
            }
            .subscribe(onNext: { (webView) in
                webView.evaluateJavaScript("window.$native.rightBarClick();", completionHandler: nil)
            })
    }

}

struct LogPlugin: HybridPlugin {
    
    static var name: String {
        return "log"
    }
    
    static func didReceive(message: Observable<(message: JSON, webView: WKWebView)>) -> Disposable {
        return message
            .subscribe(onNext: { (message, webView) in
                print(message)
            })
    }
    
}

struct DisplayImagePlugin: CallBackHybridPlugin {
    
    static var name: String {
        return "displayImage"
    }

    static func didReceive(message: JSON, webView: WKWebView) -> Observable<JSON> {
        guard let image = URL(string: message["image"].stringValue).flatMap({ try? Data(contentsOf: $0) }).flatMap({ UIImage(data: $0) }) else {
            return Observable.just(JSON([:]))
        }
        let keyWindow = UIApplication.shared.keyWindow!
        let frame = CGRect(
            x: message["x"].doubleValue,
            y: message["y"].doubleValue + Double(-webView.convert(webView.bounds.origin, from: keyWindow).y) - Double(webView.scrollView.contentOffset.y),
            width: message["width"].doubleValue,
            height: message["height"].doubleValue
        )
        let displayView = DisplayView(frame: keyWindow.bounds)
        displayView.display(image: image, frame: frame)
        return displayView.displayFinished.ifEmpty(default: ()).map { JSON([:]) }
    }
    
    private class DisplayView: UIView {
        
        let imageView = UIImageView()
        let disposeBag = DisposeBag()
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
        
        var originFrame = CGRect.zero
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.addSubview(visualEffectView)
            visualEffectView.frame = self.bounds
            self.visualEffectView.alpha = 0
            
            self.addSubview(imageView)
            self.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer()
            tap.rx.event
                .subscribe(onNext: { [weak self] _ in
                    UIView.animate(withDuration: 0.3, animations: {
                        if let `self` = self {
                            self.visualEffectView.alpha = 0
                            self.imageView.frame = self.originFrame
                        }
                    }, completion: { _ in
                        self?.displayFinished.onNext(())
                    })
                })
                .disposed(by: disposeBag)
            self.addGestureRecognizer(tap)
            self.displayFinished.debounce(0.1, scheduler: MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] in
                    self?.removeFromSuperview()
                })
                .disposed(by: disposeBag)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func display(image: UIImage, frame: CGRect) {
            self.originFrame = frame
            self.imageView.image = image
            self.imageView.frame = frame
            let view = UIApplication.shared.keyWindow!
            view.addSubview(self)
            UIView.animate(withDuration: 0.3, animations: {
                self.visualEffectView.alpha = 1
                let height = view.bounds.width / frame.width * frame.height
                let y = (view.bounds.height - height) / 2
                self.imageView.frame = CGRect(x: 0, y: y, width: view.bounds.width, height: height)
            })
        }
        
        let displayFinished = PublishSubject<()>()
    }
    
}

struct HTTPRequestPlugin: CallBackHybridPlugin {
    
    static var name: String {
        return "http"
    }
    
    static func didReceive(message: JSON, webView: WKWebView) -> Observable<JSON> {
        let query: JSON = message["query"]
        return URLSession.shared.rx.json(url: URL(string: "https://httpbin.org/get?\(query.map { "\($0)=\($1.stringValue)" }.joined(separator: "&"))")!)
            .map { JSON($0) }
    }
    
}

import MBProgressHUD

struct LoadingPlugin: HybridPlugin {
    
    static var name: String {
        return "loading"
    }
    
    static let hud: MBProgressHUD = {
        let hud = MBProgressHUD(view: UIApplication.shared.keyWindow!)
        hud.removeFromSuperViewOnHide = true
        return hud
    }()
    
    static func didReceive(message: Observable<(message: JSON, webView: WKWebView)>) -> Disposable {
        return message
            .subscribe(onNext: { (message, webView) in
                let loading = message["content"].boolValue
                if loading {
                    UIApplication.shared.keyWindow!.addSubview(hud)
                    hud.show(animated: true)
                } else {
                    hud.hide(animated: true)
                }
            })
    }
    
}

struct ToastPlugin: HybridPlugin {
    
    static var name: String {
        return "toast"
    }
    
    static let hud: MBProgressHUD = {
        let hud = MBProgressHUD(view: UIApplication.shared.keyWindow!)
        hud.mode = MBProgressHUDMode.text
        return hud
    }()
    
    static func didReceive(message: Observable<(message: JSON, webView: WKWebView)>) -> Disposable {
        return message
            .subscribe(onNext: { (message, webView) in
                let text = message["content"].stringValue
                hud.label.text = text
                UIApplication.shared.keyWindow!.addSubview(hud)
                hud.show(animated: true)
                hud.hide(animated: true, afterDelay: 1)
            })
    }
    
}

struct NavigationPlugin: HybridPlugin {
    
    static var name: String {
        return "navigation"
    }
    
    static func didReceive(message: Observable<(message: JSON, webView: WKWebView)>) -> Disposable {
        return message
            .subscribe(onNext: { (message, webView) in
                let title = message["content"]["title"].stringValue
                let nextHybrid = R.storyboard.main.hybridViewController()!
                nextHybrid.title = title
                let parentViewController = webView.parentViewController
                parentViewController?.snapshotImageView.image = webView.imageSnapshot
                parentViewController?.snapshotImageView.isHidden = false
                webView.parentViewController?.navigationController?.pushViewController(nextHybrid, animated: true)
            })
    }
    
}

struct NavigationGoPlugin: HybridPlugin {
    
    static var name: String { // 当前只支持负数 go(-2)
        return "go"
    }

    static func didReceive(message: Observable<(message: JSON, webView: WKWebView)>) -> Disposable {
        return message
            .subscribe(onNext: { (message, webView) in
                guard let navigationController = webView.parentViewController?.navigationController else { return }
                let n = abs(message["content"].intValue)
                if n < navigationController.viewControllers.count {
                    let to = navigationController.viewControllers[navigationController.viewControllers.count - n - 1]
                    webView.parentViewController?.snapshotImageView.isHidden = false
                    webView.parentViewController?.snapshotImageView.image = webView.parentViewController?.webView.imageSnapshot
                    if let to = to as? HybridViewController {
                        to.view.addSubview(Hybrid.shared.webView)
                        to.view.insertSubview(Hybrid.shared.webView, belowSubview: to.snapshotImageView)
                        
                        to.snapshotImageView.image = nil
                        to.snapshotImageView.isHidden = true
                        
                        to.webView.snp.remakeConstraints({ (make) in
                            make.edges.equalTo(to.view)
                        })
                    }
                    navigationController.popToViewController(to, animated: true)
                }
            })
    }
    
}
