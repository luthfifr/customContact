//
//  contactTVC.swift
//  CustomContact
//
//  Created by Luthfi Fathur Rahman on 7/13/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit

class contactTVC: UITableViewCell {

    @IBOutlet weak var image_pp: UIImageView!
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var label_phnumber: UILabel!
    @IBOutlet weak var label_email: UILabel!
    @IBOutlet weak var btn_call: UIButton!
    @IBOutlet weak var btn_sms: UIButton!
    @IBOutlet weak var btn_email: UIButton!
    
    override func awakeFromNib() {
        image_pp.layer.cornerRadius = image_pp.frame.size.width/2
        image_pp.clipsToBounds = true
    }
}
