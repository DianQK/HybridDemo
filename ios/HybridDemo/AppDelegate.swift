//
//  AppDelegate.swift
//  HybridDemo
//
//  Created by wc on 13/08/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }

        ScriptMessageService.plugins = [
            TitlePlugin.self,
            SelectImagePlugin.self,
            RightBarTitlePlugin.self,
            LogPlugin.self,
            DisplayImagePlugin.self,
            HTTPRequestPlugin.self,
            LoadingPlugin.self,
            NavigationPlugin.self,
            NavigationGoPlugin.self,
            ToastPlugin.self
        ]

        return true
    }


}

