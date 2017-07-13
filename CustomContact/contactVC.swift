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
    
    var activityIndicator = UIActivityIndicatorView()
    
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
        
        stopActivityIndicator()
        self.tableView.reloadData()
        
        btn_addContact.isEnabled = userContact.isEmpty
    }
    
    private func startActivityIndicator() {
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    private func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
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
                startActivityIndicator()
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
        
        cell.btn_call.tag = indexPath.row
        cell.btn_sms.tag = indexPath.row
        cell.btn_email.tag = indexPath.row
        
        
        if userContact[indexPath.row].imageDataAvailable {
            cell.image_pp.image = UIImage(data: userContact[indexPath.row].imageData!)
            cell.image_pp.contentMode = .scaleAspectFill
        } else {
            cell.image_pp.image = UIImage(named: "default_pp")
            cell.image_pp.contentMode = .scaleAspectFill
        }
        
        cell.label_name.text = userContact[indexPath.row].givenName + " " + userContact[indexPath.row].familyName
        cell.label_name.sizeToFit()
        
        if !userContact[indexPath.row].phoneNumbers.isEmpty {
            for phone in userContact[indexPath.row].phoneNumbers {
                cell.label_phnumber.text = phone.value.stringValue
                cell.label_phnumber.sizeToFit()
            }
            cell.btn_sms.isEnabled = true
            cell.btn_sms.isHidden = false
            cell.btn_call.isEnabled = true
            cell.btn_call.isHidden = false
        } else {
            cell.label_phnumber.text = ""
            cell.btn_sms.isEnabled = false
            cell.btn_sms.isHidden = true
            cell.btn_call.isEnabled = false
            cell.btn_call.isHidden = true
        }
        
        if !userContact[indexPath.row].emailAddresses.isEmpty {
            for email in userContact[indexPath.row].emailAddresses {
                cell.label_email.text = email.value as String
                cell.label_name.sizeToFit()
            }
            cell.btn_email.isEnabled = true
            cell.btn_email.isHidden = false
        } else {
            cell.label_email.text = ""
            cell.btn_email.isEnabled = false
            cell.btn_email.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! contactTVC
        
        print(currentCell.label_phnumber.text!)
    }
    
    @IBAction func btn_call(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let currentCell = tableView.cellForRow(at: indexPath) as! contactTVC
        if let phoneNumber = currentCell.label_phnumber.text {
            if let url = URL(string: "telprompt:\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @IBAction func btn_sms(_ sender: UIButton) {
        print("\(sender.tag) sms pressed")
    }
    
    @IBAction func btn_email(_ sender: UIButton) {
        print("\(sender.tag) email pressed")
    }
}

