//
//  ArticlesViewController.swift
//  HybridDemo
//
//  Created by DianQK on 2018/12/24.
//  Copyright © 2018 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

let articleViewController: HybridViewController = {
    let viewController = R.storyboard.main.hybridViewController()!
    _ = viewController.view
    return viewController
}()

class ArticlesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.just(["1"])
            .bind(to: tableView.rx.items(cellIdentifier: "TitleCell")) { (index, item, cell) in
                cell.textLabel?.text = item
            }
            .disposed(by: disposeBag)

    }

}
