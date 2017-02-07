//
//  ViewController.swift
//  iPhoneiBeaconExp
//
//  Created by Fang-Pen Lin on 2/7/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth


class ViewController: UIViewController {
    var locationManager: CLLocationManager!
    var region: CLBeaconRegion!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func monitorButtonTapped(_ sender: Any) {
        locationManager = CLLocationManager()
        locationManager.delegate = self

        locationManager.requestAlwaysAuthorization()

        let uuid = UUID(uuidString: "5E759524-B7F2-4F3A-81E6-73B2F9728AAB")!
        region = CLBeaconRegion(proximityUUID: uuid, major: 1, minor: 1, identifier: "ibeacon-test.envoy.com")

        locationManager.startMonitoring(for: region)
        print("Start monitoring region \(region)")
    }
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("did enter region \(region)")
        locationManager.startRangingBeacons(in: self.region)
        //locationManager.startRangingBeacons(in: self.region)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("did exit region \(region)")
        //locationManager.stopRangingBeacons(in: self.region)
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("Did range beacon \(beacons)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("!!!! failed, error=\(error)")
    }
}
