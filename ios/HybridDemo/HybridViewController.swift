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

extension WKWebView {

    var parentViewController: HybridViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? HybridViewController {
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

        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
//        let rc = UIRefreshControl()
//        rc.tintColor = UIColor.black
//        webView.scrollView.refreshControl = rc
        
        self.webView = webView

    }
    
    func preLoad(url: URL) {
        self.webView.load(URLRequest(url: url))
    }
    
}

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
        
//        snapshotImageView.isUserInteractionEnabled = true
        snapshotImageView.isHidden = true
        
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
        
        let navigationController = self.navigationController
        
        if let edgePanGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer as? UIScreenEdgePanGestureRecognizer {
            edgePanGestureRecognizer.rx.event
                .filter { $0.state == UIGestureRecognizer.State.ended }
                .map { [unowned self] (edgePanGestureRecognizer) -> Bool in
                    guard let view = edgePanGestureRecognizer.view else {
                        fatalError()
                    }
                    let translatedPoint = edgePanGestureRecognizer.translation(in: view)
                    return !navigationController!.viewControllers.contains(self) && (translatedPoint.x > self.view.bounds.size.width * 0.5 || edgePanGestureRecognizer.velocity(in: self.view).x > 500)
                }
                .subscribe(onNext: { [weak self, weak navigationController] pop in
                    print(pop) // pop 执行了两次
                    if pop {
                        let imageSnapshot = self?.webView.imageSnapshot
                        Hybrid.shared.webView.evaluateJavaScript("window.history.back();", completionHandler: { (_, _) in
                            if let navigationController = navigationController {
                                self?.snapshotImageView.isHidden = false
                                self?.snapshotImageView.image = imageSnapshot
                                if let pre = navigationController.viewControllers[navigationController.viewControllers.count - 1] as? HybridViewController {
                                    pre.view.addSubview(Hybrid.shared.webView)
                                    pre.view.insertSubview(Hybrid.shared.webView, belowSubview: pre.snapshotImageView)
                                    pre.webView.snp.remakeConstraints({ (make) in
                                        make.edges.equalTo(pre.view)
                                    })
//                                    pre.snapshotImageView.isHidden = true
//                                    pre.snapshotImageView.image = nil
                                }
                                
                            }
                        })
                    }
                })
                .disposed(by: disposeBag)
        }
        

    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.view.addSubview(Hybrid.shared.webView)
//        self.view.insertSubview(Hybrid.shared.webView, belowSubview: self.snapshotImageView)
//        self.webView = Hybrid.shared.webView
//        
//        self.webView.snp.remakeConstraints { (make) in
//            make.edges.equalTo(self.view)
//        }
//    }
//    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.snapshotImageView.isHidden {
            self.snapshotImageView.isHidden = true
            self.snapshotImageView.image = nil
        }
    }

//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.snapshotImageView.isHidden = false
//        if self.snapshotImageView.image == nil {
//            self.snapshotImageView.image = self.webView.imageSnapshot
//        }
//    }
    
    override func navigationShouldPopOnBackButton() -> Bool {
//        if self.webView.canGoBack {
//            self.webView.evaluateJavaScript("window.history.back();", completionHandler: nil)
//            return false
//        } else {
//            return true
//        }
        self.snapshotImageView.isHidden = false
        self.snapshotImageView.image = self.webView.imageSnapshot
        self.webView.evaluateJavaScript("window.history.back();", completionHandler: nil)
        if let pre = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2] as? HybridViewController {
            pre.view.addSubview(Hybrid.shared.webView)
            pre.view.insertSubview(Hybrid.shared.webView, belowSubview: pre.snapshotImageView)
            
            pre.snapshotImageView.image = nil
            pre.snapshotImageView.isHidden = true
            
            pre.webView.snp.remakeConstraints({ (make) in
                make.edges.equalTo(pre.view)
            })
        }
        return true
    }

}

