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
    @IBOutlet weak var msgLog: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = UserDefaults.standard
        let msgData = defaults.data(forKey: "log_msg") ?? Data()
        let msgs = String(data: msgData, encoding: .utf8) ?? ""
        msgLog.text = msgs
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func monitorButtonTapped(_ sender: Any) {
    }
}
