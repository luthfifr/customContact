//
//  ViewController.swift
//  CustomContact
//
//  Created by Luthfi Fathur Rahman on 7/10/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Contacts

class contactVC: UIViewController {

    @IBOutlet weak var btn_addContact: UIBarButtonItem!
    
    var contactStore = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btn_addContact(_ sender: UIBarButtonItem) {
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
            case .denied, .restricted:
                let alertDenied = UIAlertController (title: "Access Denied", message: "CustomContact app is not allowed to access your Contact app. Please go to Settings to grant it an access.", preferredStyle: UIAlertControllerStyle.alert)
                alertDenied.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default,handler: { (action) in
                    guard let settingsUrl = URL(string: "App-Prefs:root=Privacy&path=CONTACTS") else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                }))
                alertDenied.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil))
                self.present(alertDenied, animated: true, completion: nil)
            case .authorized:
                print("Authorized")
            case .notDetermined:
                contactStore.requestAccess(for: .contacts, completionHandler: { status, error in
                    print("contact access = \(status)")
                    
                    if error != nil {
                        print("error access to contact = \(String(describing: error))")
                    }
                })
        }
        
        
    }
    
}

