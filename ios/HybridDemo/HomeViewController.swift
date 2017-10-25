//
//  HomeViewController.swift
//  HybridDemo
//
//  Created by wc on 15/08/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Rswift

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var vueRemoteButton: UIButton!
    @IBOutlet weak var vueLocalhostButton: UIButton!
    @IBOutlet weak var reactRemoteButton: UIButton!
    @IBOutlet weak var reactLocalhostButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.merge([
            vueRemoteButton.rx.tap.asObservable().map { URL(string: "https://canlis.github.io/canlis-vue-example/#/")! },
            vueLocalhostButton.rx.tap.asObservable().map { URL(string: "http://localhost:8080/#/")! },
            reactRemoteButton.rx.tap.asObservable().map { URL(string: "https://canlis.github.io/canlis-react-example/")! },
            reactLocalhostButton.rx.tap.asObservable().map { URL(string: "http://localhost:3000/")! },
            ])
            .subscribe(onNext: { [unowned self] url in
                let hybridViewController = R.storyboard.main.hybridViewController()!
                _ = hybridViewController.view
                hybridViewController.webView.load(URLRequest(url: url))
                self.navigationController?.pushViewController(hybridViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}
