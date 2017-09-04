//
//  HybridViewController.swift
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
import Zip

extension UIView {

    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

}

public protocol HybridPlugin {
    
    static var name: String { get }
    
    static func didReceive(message: Observable<(message: JSON, webView: WKWebView)>) -> Disposable
    
}

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    
    let subject = PublishSubject<Any>()
    let disposeBag = DisposeBag()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        subject.onNext(message.body)
    }
    
}

typealias Callback = () -> ()

public class ScriptMessageService {

    static var plugins: [HybridPlugin.Type] = []
    
}

class Hybrid {
    
    static let shared = Hybrid()
    
    var webView: WKWebView!
    
    private let disposeBag = DisposeBag()
    
    init() {
        
        let configuration = WKWebViewConfiguration()

        let userContentController = WKUserContentController()
        for plugin in ScriptMessageService.plugins {
            let scriptMessageHandler = ScriptMessageHandler()
            let receive = scriptMessageHandler.subject
                .flatMap { [weak self] (message) -> Observable<(message: JSON, webView: WKWebView)> in
                    guard let `self` = self else {
                        return Observable.empty()
                    }
                    return Observable.just((message: JSON(message), webView: self.webView))
            }
            plugin.didReceive(message: receive)
                .disposed(by: scriptMessageHandler.disposeBag)
            userContentController.add(scriptMessageHandler, name: plugin.name)
        }
        configuration.userContentController = userContentController
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        self.webView = webView
        
    }
    
}

//- (UIImage*)imageSnapshot {
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size,YES,self.contentScaleFactor);
//    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}

extension UIView {
    
    var imageSnapshot: UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}

class HybridViewController: UIViewController {
    
    var webView: WKWebView!
    
    let snapshotImageView = UIImageView()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        self.view.addSubview(Hybrid.shared.webView)
        self.webView = Hybrid.shared.webView
        
        self.webView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        self.view.addSubview(snapshotImageView)
        self.snapshotImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(Hybrid.shared.webView)
        self.view.insertSubview(Hybrid.shared.webView, belowSubview: self.snapshotImageView)
        self.webView = Hybrid.shared.webView
        
        self.webView.snp.remakeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.snapshotImageView.isHidden = true
        self.snapshotImageView.image = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.snapshotImageView.isHidden = false
        if self.snapshotImageView.image == nil {
            self.snapshotImageView.image = self.webView.imageSnapshot
        }
    }
    
    override func navigationShouldPopOnBackButton() -> Bool {
//        if self.webView.canGoBack {
//            self.webView.evaluateJavaScript("window.history.back();", completionHandler: nil)
//            return false
//        } else {
//            return true
//        }
        self.webView.evaluateJavaScript("window.history.back();", completionHandler: nil)
        return true
    }

}

