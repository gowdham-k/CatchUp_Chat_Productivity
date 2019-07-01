//
//  mainChatScreenTableViewCell.swift
//  Catch Up
//
//  Created by Siva on 27/06/19.
//  Copyright © 2019 CZ Ltd. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import FirebaseStorage
import FirebaseDatabase

class mainChatScreenTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var recievedMessageLbl: UILabel!
    
    @IBOutlet weak var recievedMessageView: UIView!
    
    @IBOutlet weak var sentMessageLbl: UILabel!
    
    @IBOutlet weak var sentMessageView: UIView!
    
    @IBOutlet var receivedTimeLabel: UILabel!
    
    @IBOutlet var sentTimeLabel: UILabel!
    
    @IBOutlet var likeOrUnlikeImageView: UIImageView!
    
    @IBOutlet var errorImageView: UIImageView!
    
    
    @IBOutlet var checkImage: UIImageView!
    
    var message: Message!
    var currentUser = KeychainWrapper.standard.string(forKey: "uid")

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        sentMessageView.layer.masksToBounds  = true
        recievedMessageView.layer.masksToBounds = true
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(message: Message) {
        
        self.message = message
        
        if message.sender == currentUser {
            
            sentMessageView.isHidden = true
            
            recievedMessageView.isHidden = true
            
            sentMessageLbl.text = "   " + message.message
            
            recievedMessageLbl.isHidden = true
            
            sentMessageLbl.isHidden = true
            
        } else {
            
            sentMessageView.isHidden = false
            
            recievedMessageView.isHidden = true
            
            recievedMessageLbl.text = "   " + message.message
            
            recievedMessageLbl.isHidden = true
            
            sentMessageLbl.isHidden = false
                    
        }
    }

}
