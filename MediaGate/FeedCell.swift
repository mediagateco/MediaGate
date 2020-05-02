//
//  FeedCell.swift
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
import FirebaseStorage

class FeedCell: UITableViewCell {

    @IBOutlet weak var userEmailAddress: UILabel!
    @IBOutlet weak var likesCounter: UILabel!
    @IBOutlet weak var userComment: UILabel!
    @IBOutlet weak var documentID: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var thumbnailUrl: UILabel!
    @IBOutlet weak var videoUrl: UILabel!
    
    var delegate: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    //NOTE: The like button will be disalbed for now and this method needs to be updated in the DB once activated
    @IBAction func isLikeButtonClicked(_ sender: Any) {
        let db = Firestore.firestore()
               db.collection("Likes").addDocument(data: ["DocumentID" : documentID.text, "Email" : Auth.auth().currentUser?.email ] as [String: Any])
               //Increase the counter
               if let likeCount = Int(likesCounter.text!) {
                   let likeStore = ["likes" : likeCount + 1] as [String : Any]
                   db.collection("Posts").document(documentID.text!).setData(likeStore, merge: true)
                   let newlikeCounter = db.collection("Posts").document(documentID.text!)
                   self.likeButton.isEnabled = false
                   likesCounter.text = String(likeCount + 1)
               }
    }
    
    
    @IBAction func isDeleteButtonClicked(_ sender: Any) {

            let alert = UIAlertController(title: "حذف فيديو", message: "سيتم حذف الفيديو. هل أنت متأكد؟", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "موافق", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                print("Action")
                self.deleteVideoFromStorage()
                self.deleteThumbnailFromStorage()
                self.deletePostFromDatabase()
            }))
            alert.addAction(UIAlertAction(title: "إلغاء", style: UIAlertAction.Style.default, handler: nil))
            delegate?.present(alert, animated: true, completion: nil)
        }
    
    func deleteVideoFromStorage() {
        let vurl = String(self.videoUrl.text!.components(separatedBy: "?")[0].components(separatedBy: "%")[1].dropFirst().dropFirst())
        let videoFolder = Storage.storage().reference().child("videos")
        var storageReferencevideo = videoFolder.child(String(vurl))
        storageReferencevideo.delete { error in
            if let error = error {
                print(error)
            } else {
                // File deleted successfully
                print("video removed from storage successfully.")
            }
            
        }
        
    }
    
    func deleteThumbnailFromStorage() {
        let turl = String(self.thumbnailUrl.text!.components(separatedBy: "?")[0].components(separatedBy: "%")[1].dropFirst().dropFirst())
        let thumbnailFolder = Storage.storage().reference().child("thumbnail")
        var storageReferenceThumbnail = thumbnailFolder.child(String(turl))
        storageReferenceThumbnail.delete { error in
            if let error = error {
                print(error)
            } else {
                // File deleted successfully
                print("thumbnail removed from storage successfully.")
            }
        }
    }
    
    func deletePostFromDatabase() {
        let db = Firestore.firestore()
        db.collection("Posts").document(documentID.text!).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                    }
                }
        }
            
}
