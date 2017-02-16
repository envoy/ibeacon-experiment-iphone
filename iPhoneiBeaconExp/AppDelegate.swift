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
    var cbManager: CBCentralManager!
    var region: CLBeaconRegion!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        cbManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)

        let uuid = UUID(uuidString: "5E759524-B7F2-4F3A-81E6-73B2F9728AAB")!
        region = CLBeaconRegion(proximityUUID: uuid, major: 1, minor: 1, identifier: "ibeacon-test.envoy.com")

        locationManager.startMonitoring(for: region)

        let osVersion = UIDevice.current.systemVersion
        log("app-launch", "app launched, monitoring \(region!), os_version=\(osVersion)")
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        log("app-will-resign-active", "app will resign active")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        log("app-did-enter-background", "app did enter background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        log("app-will-enter-foreground", "app will enter foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        log("app-did-become-active", "app did become active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        log("app-will-terminate", "app will terminate")
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("did enter region \(region)")
        log("did-enter-region", "did enter region \(region)")
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("did exit region \(region)")
        log("did-exit-region", "did exit region \(region)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            log("cl-authorized-always", "CoreLocation authorized always")
        case .authorizedWhenInUse:
            log("cl-authorized-when-in-use", "CoreLocation authorized when-in-use")
        case .denied:
            log("cl-deined", "CoreLocation denied")
        case .notDetermined:
            log("cl-not-determined", "CoreLocation not determined")
        case .restricted:
            log("cl-restricted", "CoreLocation restricted")
        }
    }
}

extension AppDelegate: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            log("cb-power-on", "CoreBluetooth power on")
        case .poweredOff:
            log("cb-power-off", "CoreBluetooth power off")
        case .resetting:
            log("cb-power-resetting", "CoreBluetooth resetting")
        case .unauthorized:
            log("cb-power-unauthorized", "CoreBluetooth unauthorized")
        case .unsupported:
            log("cb-power-unsupported", "CoreBluetooth unsupported")
        case .unknown:
            log("cb-power-unknown", "CoreBluetooth unknown")
        }
    }
}

extension AppDelegate {
    func log(_ event: String, _ message: String) {
        DispatchQueue.main.async {
            let defaults = UserDefaults.standard
            let msgData = defaults.data(forKey: "log_msg") ?? Data()
            var msgs = String(data: msgData, encoding: .utf8) ?? ""

            var dict = [String: String]()
            dict["id"] = UUID.init().uuidString
            dict["event"] = event
            dict["message"] = message
            dict["created_at"] = Date().iso8601

            let json = try! JSONSerialization.data(withJSONObject: dict, options: .init(rawValue: 0))
            let jsonString = String(data: json, encoding: .utf8)!
            print(jsonString)

            msgs.append(jsonString + "\n")
            defaults.set(msgs.data(using: .utf8), forKey: "log_msg")
            defaults.set(true, forKey: "log_msg_updated")
            defaults.synchronize()
        }
    }

    func uploadLog() {
        let defaults = UserDefaults.standard
        guard let userID = defaults.value(forKey: "user_id") as? String else {
            print("User not signed up yet, skip log uploading")
            return
        }
        guard defaults.bool(forKey: "log_msg_updated") else {
            print("Log not updated, skip log uploading")
            return
        }
        guard let msgData = defaults.data(forKey: "log_msg") else {
            print("No message, skip log uploading")
            return
        }

        var bodyData = "\(userID)\n".data(using: .utf8)
        bodyData?.append(msgData)

        var request = URLRequest(url: Utils.apiURL.appendingPathComponent("upload-log"))
        request.addValue("binary/octet-stream", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = bodyData
        let task = URLSession.shared.dataTask(with: request) { (data, resp, error) in
            if let error = error {
                print("Failed to upload logs, error=\(error)")
                return
            }
            let lastID = String(data: data!, encoding: .utf8)
            print("Uploaded logs with last_id=\(lastID)")
            // TODO: trim the log before the last ID, as they are uploaded already
        }
        task.resume()
    }
}
