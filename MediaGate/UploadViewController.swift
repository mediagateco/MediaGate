//
//  UploadViewController.swift
//  MediaGate
//
//  Created by Nouha Nouman on 17/02/2020.
//  Copyright © 2020 Nouha Nouman. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import Photos
import MobileCoreServices
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth




class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var camera: UIImageView!
    @IBOutlet weak var videoDescription: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    var videoURL: URL!
    @IBOutlet weak var percentage: UILabel!
    @IBAction func goBack(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        self.camera.image = UIImage(named:"uploadicon.png")
        uploaded.isEnabled = false
        uploaded.alpha = 0.5
        cancel.isEnabled = false
        cancel.alpha = 0.5
    }
    @IBOutlet weak var uploaded: UIButton!
    
    @IBOutlet weak var cancel: UIButton!
    var thumbnailImage = ""
    var placeholderLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        camera.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.chooseImage))
        camera.addGestureRecognizer(gestureRecognizer)
        progressView.setProgress(0.0, animated: true)
        self.view.isUserInteractionEnabled = true
        self.percentage.text = ""
        
        //Make the video Description field rounded
        videoDescription.setCirular(radius: videoDescription.frame.height / 2)
        videoDescription.layer.borderWidth = 1.0
        videoDescription.layer.borderColor = UIColor.lightGray.cgColor
        
        //Disable the upload and cancel buttons by default
        uploaded.layer.cornerRadius = uploaded.frame.height / 2
        uploaded.isEnabled = false
        uploaded.alpha = 0.5
        cancel.layer.cornerRadius = cancel.frame.height / 2
        cancel.isEnabled = false
        cancel.alpha = 0.5
        
        //Add the descriptive text to the video description field
        self.videoDescription.layer.borderWidth = 1.0
        self.videoDescription.layer.borderColor = UIColor.lightGray.cgColor
        self.videoDescription.delegate = self
        setupPlaceHolder()
        
    }
    
    func setupPlaceHolder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "ارفع فيديو الأداء شرط لا يتجاوز ٩٠ ثانية و اكتب التعليق هنا"
        placeholderLabel.textAlignment = NSTextAlignment.right
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (self.videoDescription.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        self.videoDescription.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.videoDescription.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !self.videoDescription.text.isEmpty
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if (textView.text.isEmpty) {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        self.view.isUserInteractionEnabled = true
        self.progressView.setProgress(0.0, animated: true)
        self.percentage.text = ""

    }
    
    @IBAction func upload(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        let storage = Storage.storage()
        let storageReference = storage.reference()
        if(videoURL == nil) {
            //If you are uploading an image
            if let data = camera.image?.jpegData(compressionQuality: 0.5) {
                let imageFolder = storageReference.child("images")
                let uuid = UUID().uuidString
                let imageReference = imageFolder.child("\(uuid).jpg")
                imageReference.putData(data, metadata: nil) { (metadata, error) in
                    if error != nil {
                        self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                    } else {
                        imageReference.downloadURL { (url,error) in
                            if error == nil {
                                let imageUrl = url?.absoluteString
                                //Add Database Action
                                let firestoreDatabase = Firestore.firestore()
                                var firestoreReference : DocumentReference? = nil
                                let firestorePost = ["imageUrl" : imageUrl!, "postedBy" : Auth.auth().currentUser!.email!,"postComment" : self.videoDescription.text!, "date" : FieldValue.serverTimestamp(), "likes" : 0, "isVideo" : "false" ] as [String : Any]
                                firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                    if error != nil {
                                        self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                                    } else {
                                        //self.camera.image  = UIImage(systemName: "video.badge.plus")
                                        self.camera.image = UIImage(named: "uploadicon.png")
                                        self.videoDescription.text = ""
                                        self.tabBarController?.selectedIndex = 2
                                    }})}}}}}} else {
                //If the user is uploading a video
                if  ((videoURL as? NSURL) != nil) {
                    //store the thumbnail image
                    let data = camera.image?.jpegData(compressionQuality: 0.5)
                    let thumbnailFolder = storageReference.child("thumbnail")
                    let uuthumbid = UUID().uuidString
                    let storageReferenceThumb = thumbnailFolder.child("\(uuthumbid).jpg")
                    storageReferenceThumb.putData(data!, metadata: nil) { (metadata, error) in
                    if error != nil {
                        self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                    } else {
                        storageReferenceThumb.downloadURL { (url,error) in
                            if error == nil {
                                self.thumbnailImage = url!.absoluteString
                            }}}}}
                    // Where we'll store the video:
                    let videoFolder = storageReference.child("videos")
                    let uuid = UUID().uuidString
                    let storageReference = videoFolder.child("\(uuid).mov")
                    //Transfer the video to a temp url
                    let urlString = videoURL.relativeString
                    let urlSlices = urlString.split(separator: ".")
            
                    //Create a temp directory using the file name and copy the video
                    let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                    let targetURL = tempDirectoryURL.appendingPathComponent(uuid).appendingPathExtension(String(urlSlices[1]))
                    do {
                        try FileManager.default.copyItem(at: videoURL, to: targetURL)
                    } catch {
                            print("error in upload2")
                        }
                    // Start the video storage process
                    let uploadTask = storageReference.putFile(from: targetURL as URL, metadata: nil, completion: { (metadata, error) in
                      if error != nil {
                         self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                      } else {
                        storageReference.downloadURL { (url,error) in
                                if error == nil {
                                    let dataUrl = url?.absoluteString
                                    //Add Database Action
                                    //First, get the user Id
                                    let firestoreDatabase = Firestore.firestore()
                                    firestoreDatabase.collection("Users").whereField("Email", isEqualTo: Auth.auth().currentUser?.email).getDocuments { (snapshot, error) in
                                    if let error = error {
                                            print("Error in upload1. \(error)")
                                        } else {
                                            for document in snapshot!.documents {
                                                //Get the user id
                                                let userId = document.documentID
                                                var firestoreReference : DocumentReference? = nil
                                                let firestorePost = ["imageUrl" : dataUrl!, "postedBy" : Auth.auth().currentUser!.email!,"postedById" : userId,"postComment" : self.videoDescription.text!, "date" : FieldValue.serverTimestamp(), "likes" : 0, "isVideo" : "true", "thumbnailUrl" : self.thumbnailImage ] as [String : Any]
                                                firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                                if error != nil {
                                                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                                                    } else {
                                                        self.camera.image  = UIImage(named: "uploadicon.png")
                                                        self.videoDescription.text = ""
                                                        self.tabBarController?.selectedIndex = 2
                                                        self.setupPlaceHolder()
                                                    }
                                                })
                                            }
                                        }
                                    }
                                }
                        }
                          print("Video successful")
                          self.videoURL = nil
                          self.uploaded.isEnabled = false
                          self.uploaded.alpha = 0.5
                          self.cancel.isEnabled = false
                          self.cancel.alpha = 0.5
                      }
                  })
                uploadTask.observe(.progress) { snapshot in
                    self.progressView.setProgress(Float(snapshot.progress!.fractionCompleted), animated: true)
                    let p:Double = (snapshot.progress!.fractionCompleted)*100
                    let i:Int = Int(p)
                    let c = String(i)+"%"
                    self.percentage.text = c
                    }
                }
            }
    
      @objc func chooseImage() {
              let pickerController = UIImagePickerController()
              pickerController.delegate = self
              pickerController.allowsEditing = true
              pickerController.videoMaximumDuration = 90.0
              pickerController.sourceType = .savedPhotosAlbum
              pickerController.mediaTypes = [kUTTypeMovie as String]
              pickerController.videoQuality = .typeIFrame1280x720
              present(pickerController, animated: true, completion: nil)
              
          }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURLTemp = info[.mediaURL] as? URL {
            videoURL = videoURLTemp
            if let thumbnailImage = getThumbnailImage(forUrl: videoURLTemp) {
                camera.image = thumbnailImage
                uploaded.isEnabled = true
                uploaded.alpha = 1.0
                cancel.isEnabled = true
                cancel.alpha = 1.0
                
            }
        }
        else {
            camera.image = info[.originalImage] as? UIImage
            uploaded.isEnabled = false
            uploaded.alpha = 0.5
            cancel.isEnabled = false
            cancel.alpha = 0.5
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 640, height: 640)
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }

        return nil
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle:
            UIAlertController.Style.alert)
        let okButton = UIAlertAction(title:"Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    //Method to close the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Method to close the keyboard
    func textFieldShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
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


