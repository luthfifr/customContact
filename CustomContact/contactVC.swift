//
//  ViewController.swift
//  CustomContact
//
//  Created by Luthfi Fathur Rahman on 7/10/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import Contacts

class contactVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var btn_addContact: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var contactStore = CNContactStore()
    var userContact = [CNContact]()
    
    private func retrieveContacts() {
        let keys = [CNContactImageDataAvailableKey, CNContactImageDataKey, CNContactGivenNameKey, CNContactFamilyNameKey , CNContactPhoneNumbersKey, CNContactEmailAddressesKey] //CNContactFormatter.descriptorForRequiredKeys(for: .fullName)
        let request = CNContactFetchRequest(keysToFetch: keys  as [CNKeyDescriptor])
        
        try? contactStore.enumerateContacts(with: request) { (contact, error) in
            if error.hashValue != 0 {
                self.userContact.append(contact)
            } else {
                print(error)
            }
        }
        
        self.tableView.reloadData()
        
        btn_addContact.isEnabled = userContact.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
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
                            print("Settings opened: \(success)")
                        })
                    }
                }))
                alertDenied.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil))
                self.present(alertDenied, animated: true, completion: nil)
            case .authorized:
                retrieveContacts()
            case .notDetermined:
                contactStore.requestAccess(for: .contacts, completionHandler: { status, error in
                    print("contact access = \(status)")
                    
                    if error != nil {
                        print("error access to contact = \(String(describing: error))")
                    }
                })
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userContact.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath as IndexPath) as! contactTVC
        
        if userContact[indexPath.row].imageDataAvailable {
            cell.image_pp.image = UIImage(data: userContact[indexPath.row].imageData!)
            cell.image_pp.contentMode = .scaleAspectFit
        }
        
        cell.label_name.text = userContact[indexPath.row].givenName + " " + userContact[indexPath.row].familyName
        cell.label_name.sizeToFit()
        
        for phone in userContact[indexPath.row].phoneNumbers {
            cell.label_phnumber.text = phone.value.stringValue
            cell.label_phnumber.sizeToFit()
        }
        
        for email in userContact[indexPath.row].emailAddresses {
            cell.label_email.text = email.value as String
            cell.label_name.sizeToFit()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard let settingsUrl = URL(string: "App-Prefs:root=General") else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
    }
    
}

