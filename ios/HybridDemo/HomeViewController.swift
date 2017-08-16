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
    
    
    @IBOutlet weak var vueLocalFileButton: UIButton!
    @IBOutlet weak var vueLocalhostButton: UIButton!
    @IBOutlet weak var reactLocalFileButton: UIButton!
    @IBOutlet weak var reactLocalhostButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.merge([
            vueLocalFileButton.rx.tap.asObservable().map { URL(string: vueWebServer.serverURL!.absoluteString + "#/")! },
            vueLocalhostButton.rx.tap.asObservable().map { URL(string: "http://localhost:8080")! },
            reactLocalFileButton.rx.tap.asObservable().map { URL(string: reactWebServer.serverURL!.absoluteString)! },
            reactLocalhostButton.rx.tap.asObservable().map { URL(string: "http://localhost:3000")! },
            ])
            .subscribe(onNext: { url in
                self.performSegue(withIdentifier: R.segue.homeViewController.showHybrid, sender: url)
            })
            .disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segue = R.segue.homeViewController.showHybrid(segue: segue) {
            _ = segue.destination.view
            segue.destination.webView.load(URLRequest(url: sender as! URL))
        }
    }
}
