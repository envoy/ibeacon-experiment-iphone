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
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var logSyncLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateUI()

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "info-update"), object: nil, queue: nil) { _ in
            self.updateUI()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateUI() {
        let defaults = UserDefaults.standard
        if let userID = defaults.value(forKey: "user_id") as? String {
            userIDLabel.isHidden = false
            userIDLabel.text = "User ID: \(userID)"
            usernameTextField.isHidden = true
            signupButton.isHidden = true
            logSyncLabel.isHidden = false
        } else {
            userIDLabel.isHidden = true
            usernameTextField.isHidden = false
            signupButton.isHidden = false
            logSyncLabel.isHidden = true
        }

        if let lastID = defaults.value(forKey: "last_log_sync_id") as? String {
            logSyncLabel.text = "Log sync: \(lastID)"
        }
    }

    @IBAction func signupButtonTapped(_ sender: Any) {
        let deviceModel = UIDevice.current.modelCode
        let osVersion = UIDevice.current.systemVersion
        let userName = usernameTextField.text!
        guard userName.characters.count > 0 else {
            return
        }
        var request = URLRequest(url: Utils.apiURL.appendingPathComponent("users"))
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = Utils.urlEncode(dict: [
            "device_model": deviceModel,
            "os_version": osVersion,
            "username": userName
        ]).data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { (data, resp, error) in
            if let error = error {
                print("Failed to sign up, error=\(error)")
                return
            }
            guard (resp as! HTTPURLResponse).statusCode == 200 else {
                print("Failed to create user, code=\((resp as! HTTPURLResponse).statusCode)")
                return
            }
            let userID = String(data: data!, encoding: .utf8)
            print("Created user \(userID)")
            DispatchQueue.main.async {
                let defaults = UserDefaults.standard
                defaults.set(userID, forKey: "user_id")
                defaults.synchronize()
                self.updateUI()
            }
        }
        task.resume()
    }

    @IBAction func uploadLogButtonTapped(_ sender: Any) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.uploadLog()
    }
}
