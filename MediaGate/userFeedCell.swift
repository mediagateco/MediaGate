//
//  userFeedCell.swift
//  MediaGate
//
//  Created by Nouha Nouman on 17/02/2020.
//  Copyright © 2020 Nouha Nouman. All rights reserved.
//

import UIKit
import WebKit
import Firebase
import AVFoundation
import AVKit
import FirebaseFirestore
import FirebaseAuth



class userFeedCell: UITableViewCell {

    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var likesCounter: UILabel!
    @IBOutlet weak var userComment: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var documentID: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func isLikeButtonClicked(_ sender: Any) {
        let db = Firestore.firestore()
        //query user Id first
        db.collection("Users").whereField("Email", isEqualTo: Auth.auth().currentUser?.email).getDocuments {
            (snapshot, error) in
            if let error = error {
                print("Error in isLikeButtonClicked. \(error)")
                } else {
                    for document in snapshot!.documents {
                    //Get the user id
                    let userId = document.documentID
                        db.collection("Likes").addDocument(data: ["DocumentID" : self.documentID.text, "Email" : Auth.auth().currentUser?.email, "LikedById" : userId ] as [String: Any])
                }
            }
        }
        likeButton.isEnabled = false
        likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        //Increase the counter
        if let likeCount = Int(likesCounter.text!) {
            let likeStore = ["likes" : likeCount + 1] as [String : Any]
            db.collection("Posts").document(documentID.text!).setData(likeStore, merge: true)
            let newlikeCounter = db.collection("Posts").document(documentID.text!)
            self.likeButton.isEnabled = false
            likesCounter.text = String(likeCount + 1)
        }
    }
}

