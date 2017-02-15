//
//  AppDelegate.swift
//  iPhoneiBeaconExp
//
//  Created by Fang-Pen Lin on 2/7/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var locationManager: CLLocationManager!
    var region: CLBeaconRegion!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        let uuid = UUID(uuidString: "5E759524-B7F2-4F3A-81E6-73B2F9728AAB")!
        region = CLBeaconRegion(proximityUUID: uuid, major: 1, minor: 1, identifier: "ibeacon-test.envoy.com")

        locationManager.startMonitoring(for: region)

        let request = URLRequest(url: URL(string: "http://10.1.1.121:5000/app-launched")!)
        let task = URLSession.shared.dataTask(with: request) { (data, resp, error) in
            print("@@@@@@ \(data), \(resp), \(error)")
        }
        task.resume()
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("did enter region \(region)")
        locationManager.startRangingBeacons(in: self.region)

        let request = URLRequest(url: URL(string: "http://10.1.1.121:5000/enter")!)
        let task = URLSession.shared.dataTask(with: request) { (data, resp, error) in
            print("@@@@@@ \(data), \(resp), \(error)")
        }
        task.resume()
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("did exit region \(region)")
        locationManager.stopRangingBeacons(in: self.region)

        let request = URLRequest(url: URL(string: "http://10.1.1.121:5000/exit")!)
        let task = URLSession.shared.dataTask(with: request) { (data, resp, error) in
            print("@@@@@@ \(data), \(resp), \(error)")
        }
        task.resume()
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("Did range beacon \(beacons)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("!!!! failed, error=\(error)")
    }
}

extension AppDelegate {
    func log(_ message: String) {
        let defaults = UserDefaults.standard
        let msgData = defaults.data(forKey: "log_msg") ?? Data()
        var msgs = String(data: msgData, encoding: .utf8) ?? ""
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZZ"
        dateFormatter.locale = Locale.current
        msgs.append("\(dateFormatter.string(from: date)) \(message)\n")
        defaults.set(msgs.data(using: .utf8), forKey: "log_msg")
        defaults.synchronize()
    }
}
