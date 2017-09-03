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
    
    static func didReceive(message: Observable<(message: JSON, webView: WKWebView, viewController: UIViewController)>) -> Disposable
    
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

class HybridViewController: UIViewController {
    
    var webView: WKWebView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let configuration = WKWebViewConfiguration()
        
        let userContentController = WKUserContentController()
        for plugin in ScriptMessageService.plugins {
            let scriptMessageHandler = ScriptMessageHandler()
            let receive = scriptMessageHandler.subject
                .flatMap { [weak self] (message) -> Observable<(message: JSON, webView: WKWebView, viewController: UIViewController)> in
                    guard let `self` = self else {
                        return Observable.empty()
                    }
                    return Observable.just((message: JSON(message), webView: self.webView, viewController: self))
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
        
        self.view.addSubview(webView)
        self.webView = webView

        self.webView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(64)
            make.leading.bottom.trailing.equalTo(self.view)
        }

        webView.allowsBackForwardNavigationGestures = true
//        webView.load(URLRequest(url: URL(string: vueWebServer.serverURL!.absoluteString + "#/")!))
        
//        let back = UIBarButtonItem()
//        back.title = "返回"
//        back.rx.tap
//            .subscribe(onNext: { [unowned self] in
//                if self.webView.canGoBack {
//                    self.webView.evaluateJavaScript("window.history.back();", completionHandler: nil)
//                } else {
//                    self.navigationController?.popViewController(animated: true)
//                }
//            })
//            .disposed(by: disposeBag)
//        self.navigationItem.leftBarButtonItem = back
        
//        webView.rx.observe(Bool.self, "canGoBack").map { $0 ?? false }
//            .bind(to: back.rx.isEnabled)
//            .disposed(by: disposeBag)
        

    }
    
    override func navigationShouldPopOnBackButton() -> Bool {
        if self.webView.canGoBack {
            self.webView.evaluateJavaScript("window.history.back();", completionHandler: nil)
            return false
        } else {
            return true
        }
    }


}

