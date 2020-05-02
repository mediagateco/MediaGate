//
//  UserDetailsViewController.swift
//  MediaGate
//
//  Created by Nouha Nouman on 17/02/2020.
//  Copyright © 2020 Nouha Nouman. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import AVKit
import FirebaseFirestore
import FirebaseAuth


class UserDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var UserDetailsPhoto: UIImageView!
    @IBOutlet weak var userDetailsEmail: UILabel!
    @IBOutlet weak var userDetailsSpecialization: UILabel!
    @IBOutlet weak var userDetailsNationality: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userDetailsName: UILabel!
    var userID = ""
    
    class Post {
        var documentID: String
        var email: String
        var like : Int
        var imageurl : String
        var isVideo : String
        var comment : String
        var thumbnailurl : String

        init(documentID: String, email: String, like: Int, imageurl: String, isVideo: String, comment: String, thumbnailurl: String) {
            self.documentID = documentID
            self.email = email
            self.like = like
            self.imageurl = imageurl
            self.isVideo = isVideo
            self.comment = comment
            self.thumbnailurl = thumbnailurl
            
        }
    }
    
    var posts = [Post]()
    var selectedurl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.UserDetailsPhoto.layer.cornerRadius = self.UserDetailsPhoto.frame.size.width/2
        self.UserDetailsPhoto.clipsToBounds = true
        self.UserDetailsPhoto.image =  UIImage(systemName: "camera.circle.fill")
        self.UserDetailsPhoto.layer.borderWidth = 1.0
        self.UserDetailsPhoto.layer.borderColor = UIColor.clear.cgColor
        if(userID != "") {
            loadUserData()
            tableView.delegate = self
            tableView.dataSource = self
            loadposts()
        }
    }
    
    func loadUserData() {
        let db = Firestore.firestore()
        let docRef = db.collection("Users").document(self.userID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.userDetailsName.text = document.data()!["Name"] as! String
                self.userDetailsEmail.text = document.data()!["Email"] as! String
                self.userDetailsNationality.text = document.data()!["Nationality"] as! String
                self.userDetailsSpecialization.text = document.data()!["Specialization"] as! String
//                self.UserDetailsPhoneNumber.text = document.data()!["PhoneNumber"] as! String
                if(document.data()?["ProfilePhotoUrl"] != nil) {
                    self.UserDetailsPhoto.sd_setImage(with: URL(string: document.data()!["ProfilePhotoUrl"] as! String))
                }

            }
            
        }
    }
    
    func loadposts() {
        DispatchQueue.global(qos: .userInitiated).async {
            let fireStoreDatabase = Firestore.firestore()
            let docRef = fireStoreDatabase.collection("Users").document(self.userID)
            docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                fireStoreDatabase.collectionGroup("Posts")
                .whereField("postedBy", isEqualTo: document.data()!["Email"] as! String)
                .order(by: "date", descending: true)
                .addSnapshotListener() { (snapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                } else {
                        do {
                            if snapshot?.isEmpty != true && snapshot != nil {
                                self.posts.count > 0
                                self.posts.removeAll()
                                for document in snapshot!.documents {
                                    let documentIDtxt = document.documentID
                                    let commenttxt = document.get("postComment") as! String
                                    let likesnum = document.get("likes") as! Int
                                    let emailtxt = document.get("postedBy") as! String
                                    let imageUrl = document.get("imageUrl") as! String
                                    let isVideo = document.get("isVideo") as! String
                                    let thumbnailurl = document.get("thumbnailUrl") as! String
                                    let post = Post(documentID: documentIDtxt, email: emailtxt, like: likesnum, imageurl: imageUrl, isVideo: isVideo, comment: commenttxt, thumbnailurl: thumbnailurl)
                                    self.posts.append(post)
                             }
                                DispatchQueue.main.async {
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    self.tableView.reloadData()
                                }}
                    } catch {DispatchQueue.main.async {
                        //self.present(alertController, animated: true, completion: nil)
                        }}}}}}}}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "uCell", for: indexPath) as! userFeedCell
        
        /********************for Sync***********/
            //1
            if cell.accessoryView == nil {
                let indicator = UIActivityIndicatorView(style: .gray)
                cell.accessoryView = indicator
            }
            let indicator = cell.accessoryView as! UIActivityIndicatorView
        /***********************************************/
        
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.systemBackground
            cell.selectedBackgroundView = backgroundView
        
            cell.likesCounter!.text = String(posts[indexPath.row].like)
            cell.userComment!.text = posts[indexPath.row].comment
            cell.documentID!.text = posts[indexPath.row].documentID
            cell.likeButton.isEnabled = false
            
            //Check if the Like button should be disabled
            let db = Firestore.firestore()
            db.collection("Likes").whereField("DocumentID", isEqualTo: posts[indexPath.row].documentID).getDocuments { (snapshot, error) in
            if let error = error {
                    print("Error in tableView in UserDetailsViewController. \(error)")
                } else {
                var found = false
                    for document in snapshot!.documents {
                        let likedDocumentEmail = document.data()["Email"] as! String
                        if(likedDocumentEmail == Auth.auth().currentUser?.email ) {
                            found = true
                            cell.likeButton.isEnabled = false
                            cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                        }
                    }
                if (found == false) {
                    cell.likeButton.isEnabled = true
                    cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            }
        }

            if (posts[indexPath.row].isVideo == "false") {
                cell.imageView?.isHidden = false
                cell.videoThumbnail!.sd_setImage(with: URL(string: posts[indexPath.row].imageurl))
                return cell

            } else {
                let videourl = NSURL(string: posts[indexPath.row].thumbnailurl)
                cell.videoThumbnail.sd_setImage(with: URL(string: posts[indexPath.row].thumbnailurl))
                cell.videoThumbnail.isUserInteractionEnabled = true
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playVideo))
                cell.videoThumbnail.addGestureRecognizer(gestureRecognizer)
            }
        return cell
        
    }
    
    @objc func playVideo(sender:UITapGestureRecognizer) {
        let p = sender.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        selectedurl = posts[indexPath!.row].imageurl
        self.performSegue(withIdentifier: "showUserVideoPlayer", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showUserVideoPlayer") {
            let destination = segue.destination as! AVPlayerViewController
            let movieUrl:NSURL? = NSURL(string: self.selectedurl)
            if let videourl = movieUrl {
                let player = AVPlayer(url: videourl as URL)
                destination.player = player
                destination.player?.play()
            }
        }
    }

    func makeAlert(titleInput: String, messageInput: String) {
           
           let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle:
               UIAlertController.Style.alert)
           let okButton = UIAlertAction(title:"Ok", style: UIAlertAction.Style.default, handler: nil)
           alert.addAction(okButton)
           self.present(alert, animated: true, completion: nil)
       }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
