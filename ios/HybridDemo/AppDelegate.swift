//
//  AppDelegate.swift
//  HybridDemo
//
//  Created by wc on 13/08/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import GCDWebServer
import Zip

let vueWebServer = GCDWebServer()
let reactWebServer = GCDWebServer()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        ScriptMessageService.plugins = [
            TitlePlugin.self,
            SelectImagePlugin.self,
            RightBarTitlePlugin.self,
            LogPlugin.self,
            DisplayImagePlugin.self,
            HTTPRequestPlugin.self
        ]
        
        let vueFilePath = R.file.vueZip()!
        let documentsDirectory = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
        
        if !FileManager().fileExists(atPath: documentsDirectory.appendingPathComponent("vue").appendingPathComponent("index.html").absoluteString.replacingOccurrences(of: "file://", with: "")) {
            do {
                try Zip.unzipFile(vueFilePath, destination: documentsDirectory.appendingPathComponent("vue"), overwrite: true, password: nil, progress: { (progress) -> () in
                    print(progress)
                })
            }
            catch {
                print("Something went wrong")
            }
        }
        
        let reactFilePath = R.file.reactZip()!
        
        if !FileManager().fileExists(atPath: documentsDirectory.appendingPathComponent("react").appendingPathComponent("index.html").absoluteString.replacingOccurrences(of: "file://", with: "")) {
            do {
                try Zip.unzipFile(reactFilePath, destination: documentsDirectory.appendingPathComponent("react"), overwrite: true, password: nil, progress: { (progress) -> () in
                    print(progress)
                })
            }
            catch {
                print("Something went wrong")
            }
        }

        vueWebServer.addGETHandler(forBasePath: "/", directoryPath: documentsDirectory.appendingPathComponent("vue").absoluteString.replacingOccurrences(of: "file://", with: ""), indexFilename: "index.html", cacheAge: 300, allowRangeRequests: true)
        vueWebServer.start(withPort: 7080, bonjourName: nil)
        
        reactWebServer.addGETHandler(forBasePath: "/", directoryPath: documentsDirectory.appendingPathComponent("react").absoluteString.replacingOccurrences(of: "file://", with: ""), indexFilename: "index.html", cacheAge: 300, allowRangeRequests: true)
        reactWebServer.start(withPort: 7081, bonjourName: nil)

        return true
    }


}

