//
//  ProfileViewController.swift
//  MediaGate
//
//  Created by Nouha Nouman on 17/02/2020.
//  Copyright © 2020 Nouha Nouman. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import AVFoundation
import AVKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage



class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileID: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileSpecialization: UILabel!
    
    @IBOutlet weak var profileNationality: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
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

    @IBAction func Logout(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "ToViewController", sender: nil)
        } catch {
            print("error in logout.")
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.image = UIImage(systemName: "camera.circle.fill")
        self.profileImageView.layer.borderWidth = 1.0
        self.profileImageView.layer.borderColor = UIColor.clear.cgColor
        
        self.profileImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        self.profileImageView.addGestureRecognizer(gestureRecognizer)
        self.emailAddress.text = Auth.auth().currentUser?.email
        loadUserData()
        tableView.delegate = self
        tableView.dataSource = self
        loadposts()

        
    }
    
    func loadUserData() {
        print("The email is: " + (Auth.auth().currentUser?.email)!)
        let db = Firestore.firestore()
        db.collection("Users").whereField("Email", isEqualTo: Auth.auth().currentUser?.email).getDocuments { (snapshot, error) in
                if let error = error {
                        print("Error in loading user data from ProfileViewController \(error)")
                    } else {
                        for document in snapshot!.documents {
                            self.profileSpecialization.text =  document.data()["Specialization"] as! String
                            self.profileNationality.text =  document.data()["Nationality"] as! String
                            self.profileName.text = document.data()["Name"] as! String
                            if(document.data()["ProfilePhotoUrl"] != nil) {
                                self.profileImageView.sd_setImage(with: URL(string: document.data()["ProfilePhotoUrl"] as! String))
                                
                    }
                    
                }
                    
            }
             
        }
    }
        

    @objc func chooseImage() {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
        
    }
            
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //First, get the edited Image based on the selected square from the imaePickerController
        let img = info[.editedImage] as? UIImage
        self.profileImageView.image = img
        self.dismiss(animated: true, completion: nil)

        let db = Firestore.firestore()
        db.collection("Users").whereField("Email", isEqualTo: Auth.auth().currentUser?.email).getDocuments { (snapshot, error) in
                if let error = error {
                        print("Error in imagePickerController in ProfileViewController \(error)")
                    } else {
                        for document in snapshot!.documents {
                        //Upload the Image in storage
                        let data = self.profileImageView.image?.jpegData(compressionQuality: 0.5)
                        let storage = Storage.storage()
                        let storageReference = storage.reference()
                        let imageFolder = storageReference.child("images")
                        let uuid = UUID().uuidString
                        let imageReference = imageFolder.child("\(uuid).jpg")
                            imageReference.putData(data!, metadata: nil) { (metadata, error) in
                            if error != nil {
                                self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                            } else {
                                imageReference.downloadURL { (url,error) in
                                    if error == nil {
                                        let profileUrl = url?.absoluteString
                        //Set the URL of the image to the user
                        let imageStore = ["ProfilePhotoUrl" : profileUrl] as [String: Any]
                        db.collection("Users").document(document.documentID).setData(imageStore, merge: true)
                                        }
                                    
                                    }
                                
                                }
                            }
                        }
                    }
                }
        }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
            //set the background when cell is selected
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.systemBackground
            cell.selectedBackgroundView = backgroundView
        
            cell.delegate = self
            cell.userEmailAddress!.text = posts[indexPath.row].email
            cell.likesCounter!.text = String(posts[indexPath.row].like)
            cell.userComment!.text = posts[indexPath.row].comment
            cell.documentID!.text = posts[indexPath.row].documentID
            cell.likeButton.isEnabled = false
            cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            cell.videoUrl!.text = posts[indexPath.row].imageurl
            cell.thumbnailUrl!.text = posts[indexPath.row].thumbnailurl
        
            //NOTE: currently the like button will be disalbed from the ProfileViewController screen
            //Check if the Like button should be disabled
//            let db = Firestore.firestore()
//            db.collection("Likes").whereField("DocumentID", isEqualTo: posts[indexPath.row].documentID).getDocuments { (snapshot, error) in
//            if let error = error {
//                    print("Error. \(error)")
//                } else {
//                    for document in snapshot!.documents {
//                        let likedDocumentEmail = document.data()["Email"] as! String
//                        if(likedDocumentEmail == Auth.auth().currentUser?.email ) {
//                            cell.likeButton.isEnabled = false
//                            cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//                        }
//                    }
//                }
//            }

            if (posts[indexPath.row].isVideo == "false") {
                cell.imageView?.isHidden = false
                cell.videoThumbnail!.sd_setImage(with: URL(string: posts[indexPath.row].imageurl))
                return cell

            } else {
                if(posts.count == 1) {
                    cell.deleteButton.isEnabled = false
                } else {
                    cell.deleteButton.isEnabled = true
                }
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
        self.performSegue(withIdentifier: "showVideoPlayer", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showVideoPlayer") {
            let destination = segue.destination as! AVPlayerViewController
            let movieUrl:NSURL? = NSURL(string: self.selectedurl)
            if let videourl = movieUrl {
                let player = AVPlayer(url: videourl as URL)
                destination.player = player
                destination.player?.play()
            }
        }
    }

    func loadposts() {
        DispatchQueue.global(qos: .userInitiated).async {
            let fireStoreDatabase = Firestore.firestore()
            fireStoreDatabase.collectionGroup("Posts")
                .whereField("postedBy", isEqualTo: Auth.auth().currentUser?.email)
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
                        let post = Post(documentID: documentIDtxt, email: emailtxt, like: likesnum, imageurl: imageUrl, isVideo: isVideo, comment: commenttxt,thumbnailurl: thumbnailurl )
                        self.posts.append(post)
                    }
                        DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.tableView.reloadData()}}
                    } catch {
                        DispatchQueue.main.async {
                        //self.present(alertController, animated: true, completion: nil)
                        }}}}}}
    
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
