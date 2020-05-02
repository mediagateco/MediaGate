//
//  PhotoFeedViewController.swift
//  MediaGate
//
//  Created by Nouha Nouman on 17/02/2020.
//  Copyright © 2020 Nouha Nouman. All rights reserved.
//
import UIKit
import Firebase
import SDWebImage
import FirebaseFirestore



class PhotoFeedViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var photoCollection: UICollectionView!
    
    var imageData: [String] = [String]()
    var imageID: [String] = [String]()
    var imageCounter: Int = 0
    var selectedID = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        photoCollection.delegate = self
        photoCollection.dataSource = self
        loadImages()
    }
    
    func loadImages() {
        
        let db = Firestore.firestore()
        db.collection("Users").getDocuments { (snapshot, error) in
                if let error = error {
                        print("Error. \(error)")
                    } else {
                    for document in snapshot!.documents {
                        if(document.data()["ProfilePhotoUrl"] != nil) {
                            self.imageID.append(document.documentID)
                            let photoUrl = document.data()["ProfilePhotoUrl"] as! String
                            self.imageData.append(photoUrl)
                            self.photoCollection.reloadData()
                    }
        
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocellId", for: indexPath) as! ProfilePhotoViewCell
            var currImage:String = ""
            var currID: String = ""
            if(self.imageData != nil && self.imageID != nil) {
                currID = self.imageID[self.imageCounter]
                currImage = self.imageData[self.imageCounter]
                imageCounter += 1
                if imageCounter >= imageData.count {
                    imageCounter = 0

                }
                cell.documentID.text = currID
                cell.studentImage.sd_setImage(with: URL(string: currImage))
                cell.studentImage.layer.cornerRadius = cell.studentImage.frame.size.width/2
                cell.studentImage.layer.masksToBounds = false
                cell.studentImage.frame = cell.bounds
                cell.studentImage.clipsToBounds = true
                cell.studentImage.contentMode = UIView.ContentMode.scaleAspectFill
                cell.studentImage.isUserInteractionEnabled = true
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToUserDetails))
                cell.studentImage.addGestureRecognizer(gestureRecognizer)
        }

            return cell

        }
    
        @objc func goToUserDetails(sender:UITapGestureRecognizer){
            let p = sender.location(in: self.photoCollection)
            let indexPath = self.photoCollection.indexPathForItem(at: p)
            var cell = self.photoCollection.cellForItem(at: indexPath!) as! ProfilePhotoViewCell
            selectedID = cell.documentID.text!

           self.performSegue(withIdentifier: "ToUserDetails", sender: nil)
        }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if segue.identifier == "ToUserDetails" {
                let destinationVC = segue.destination as! UserDetailsViewController
                destinationVC.userID = self.selectedID
                
            }
        }
    
        func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.imageData.count
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
               let padding: CGFloat =  15
               let collectionViewSize = collectionView.frame.size.width - padding
               return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
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
