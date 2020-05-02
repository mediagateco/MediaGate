//
//  ProfileRollerViewController.swift
//  MediaGate
//
//  Created by Nouha Nouman on 21/03/2020.
//  Copyright © 2020 Nouha Nouman. All rights reserved.
//

import UIKit
import Firebase

class ProfileRollerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var dataModel = [[Profile]]()
    var dataModel2 = [String : [Profile]]()
    
    var tvPresentingArray = [Profile]()
    var voiceOverArray = [Profile]()
    var mcArray = [Profile]()
    var contentCreatorArray = [Profile]()
    var singingArray = [Profile]()
    var actingArray = [Profile]()
    var selectedID = ""
    var tableCellHeight = 0
    let specialization : [String] = [
    "تقديم تلفزيوني",
    "فويس أوفر",
    "تقديم فعاليات",
    "صناعة محتوى",
    "غناء",
    "تمثيل"
    ]
    
    //Pull to Refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ProfileRollerViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.lightGray
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.isScrollEnabled = true
        
        loadArray(specialty: specialization[0]) {
            self.tableView.reloadData()
        }
        
        loadArray(specialty: specialization[1]) {
            self.tableView.reloadData()
        }
        
        loadArray(specialty: specialization[2]) {
            self.tableView.reloadData()
        }
        
        loadArray(specialty: specialization[3]) {
            self.tableView.reloadData()
        }
        loadArray(specialty: specialization[4]) {
            self.tableView.reloadData()
        }
        
        loadArray(specialty: specialization[5]) {
            self.tableView.reloadData()
        }
        
        //Pull to Refresh
        self.tableView.addSubview(self.refreshControl)
        
    }
    
    //Pull to Refresh
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        self.tvPresentingArray.removeAll()
        self.voiceOverArray.removeAll()
        self.mcArray.removeAll()
        self.contentCreatorArray.removeAll()
        self.actingArray.removeAll()
        self.singingArray.removeAll()
        
        loadArray(specialty: specialization[0]) {
            self.tableView.reloadData()
        }
        
        loadArray(specialty: specialization[1]) {
            self.tableView.reloadData()
        }
        
        loadArray(specialty: specialization[2]) {
            self.tableView.reloadData()
        }
        
        loadArray(specialty: specialization[3]) {
            self.tableView.reloadData()
        }
        loadArray(specialty: specialization[4]) {
            self.tableView.reloadData()
        }
        
        loadArray(specialty: specialization[5]) {
            self.tableView.reloadData()
        }
        
        refreshControl.endRefreshing()
    }
    
    //TODO: NEED TO REFINE THE FILER IN THE FUTURE THE VALUES RETURNED MIGHT NOT ALL BE DISPLAYED
    //SINCE SOME OF THE STUDENTS DON'T HAVE PROFILE PICTURES
    func loadArray(specialty: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("Users")
        .whereField("Specialization", isEqualTo: specialty)
        //.limit(to: 3)
        .getDocuments { (snapshot, error) in
        if let error = error {
                print("Error in loadArrayin ProfileRollerViewController. \(error)")
            } else {
            switch specialty{
            case  "تقديم تلفزيوني":
                for document in snapshot!.documents {
                    if(document.get("ProfilePhotoUrl") != nil) {
                        let nametxt = document.get("Name") as! String
                        let photoUrltxt = document.get("ProfilePhotoUrl") as! String
                        let specializationtxt = document.get("Specialization") as! String
                        let idtxt = document.documentID as! String
                        let profile = Profile(name: nametxt, photoUrl: photoUrltxt,specilization: specializationtxt, id: idtxt)
                        self.tvPresentingArray.append(profile)
                    } else {
                        // do nothing
                    }
                    completion()
                }
            case "فويس أوفر":
                for document in snapshot!.documents {
                    if(document.get("ProfilePhotoUrl") != nil) {
                        let nametxt = document.get("Name") as! String
                        let photoUrltxt = document.get("ProfilePhotoUrl") as! String
                        let specializationtxt = document.get("Specialization") as! String
                        let idtxt = document.documentID as! String
                        let profile = Profile(name: nametxt, photoUrl: photoUrltxt,specilization: specializationtxt, id: idtxt)
                        self.voiceOverArray.append(profile)
                    } else {
                        // do nothing
                    }
                    completion()
                }
            case  "تقديم فعاليات":
                for document in snapshot!.documents {
                    if(document.get("ProfilePhotoUrl") != nil) {
                        let nametxt = document.get("Name") as! String
                        let photoUrltxt = document.get("ProfilePhotoUrl") as! String
                        let specializationtxt = document.get("Specialization") as! String
                        let idtxt = document.documentID as! String
                        let profile = Profile(name: nametxt, photoUrl: photoUrltxt,specilization: specializationtxt, id: idtxt)
                        self.mcArray.append(profile)
                    } else {
                        // do nothing
                    }
                    completion()
                }
            case  "صناعة محتوى":
                for document in snapshot!.documents {
                    if(document.get("ProfilePhotoUrl") != nil) {
                        let nametxt = document.get("Name") as! String
                        let photoUrltxt = document.get("ProfilePhotoUrl") as! String
                        let specializationtxt = document.get("Specialization") as! String
                        let idtxt = document.documentID as! String
                        let profile = Profile(name: nametxt, photoUrl: photoUrltxt,specilization: specializationtxt, id: idtxt)
                        self.contentCreatorArray.append(profile)
                    } else {
                        // do nothing
                    }
                    completion()
                }
            case  "غناء":
                for document in snapshot!.documents {
                    if(document.get("ProfilePhotoUrl") != nil) {
                        let nametxt = document.get("Name") as! String
                        let photoUrltxt = document.get("ProfilePhotoUrl") as! String
                        let specializationtxt = document.get("Specialization") as! String
                        let idtxt = document.documentID as! String
                        let profile = Profile(name: nametxt, photoUrl: photoUrltxt,specilization: specializationtxt, id: idtxt)
                        self.singingArray.append(profile)
                    } else {
                        // do nothing
                    }
                    completion()
                }
            default:
                for document in snapshot!.documents {
                    if(document.get("ProfilePhotoUrl") != nil) {
                        let nametxt = document.get("Name") as! String
                        let photoUrltxt = document.get("ProfilePhotoUrl") as! String
                        let specializationtxt = document.get("Specialization") as! String
                        let idtxt = document.documentID as! String
                        let profile = Profile(name: nametxt, photoUrl: photoUrltxt,specilization: specializationtxt, id: idtxt)
                        self.actingArray.append(profile)
                    } else {
                        // do nothing
                    }
                    completion()
                }
            }
          }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return specialization.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileRollerCell", for: indexPath) as! ProfileRollerTableViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 166/255, green: 197/255, blue: 198/255, alpha: 1.0 )
        cell.selectedBackgroundView = backgroundView
        
        switch indexPath.row {
                case 0:
                    cell.labelImage.image = UIImage(named:"TV2d.png")
                    
                case 1:
                    cell.labelImage.image = UIImage(named:"voiceover2d.png")
            
                case 2:
                    cell.labelImage.image = UIImage(named:"MC2d.png")
                
                case 3:
                    cell.labelImage.image = UIImage(named:"Content2d.png")
            
                case 4:
                    cell.labelImage.image = UIImage(named:"singing2d.png")

                default:
                    cell.labelImage.image = UIImage(named:"acting2d.png")

        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cell = cell as? ProfileRollerTableViewCell {
            cell.setCollectionViewDelegate(delegate: self, forRow: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableCellHeight = Int(tableView.frame.size.height)/Int((7))
        //If the device is iphone8 CDMA
        if(UIDevice.current.modelName == "iPhone10,1") {
            return (tableView.frame.size.height)/6
          //If the device is iphone8 GSM
        } else if (UIDevice.current.modelName == "iPhone10,4") {
            return (tableView.frame.size.height)/6
          //If the device is iphoneX CDMA
        } else if (UIDevice.current.modelName == "iPhone10,3") {
            return (tableView.frame.size.height)/6
            //If the device is iphoneX GSM
        } else if (UIDevice.current.modelName == "iPhone10,6") {
            return (tableView.frame.size.height)/6
            //If the device is iphoneXS
        } else if (UIDevice.current.modelName == "iPhone11,2") {
            return (tableView.frame.size.height)/6
            //IF the devie is iphoneXR
        } else if (UIDevice.current.modelName == "iPhone11,8") {
            return (tableView.frame.size.height)/6
             //IF the device is iphone8 simulator
        } else if (UIDevice.current.modelName == "x86_64") {
            return (tableView.frame.size.height)/6
        } else {
            return (tableView.frame.size.height)/6
        }
    }
}

extension ProfileRollerViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return dataModel[collectionView.tag].count
        switch collectionView.tag {
                case 0:
                    
                    return self.tvPresentingArray.count
                    
                case 1:
                
                    return self.voiceOverArray.count
                    
                case 2:
                    return self.mcArray.count
                
                case 3:
                    return self.contentCreatorArray.count
                
                case 4:
                    return self.singingArray.count

                default:
                    return self.actingArray.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileRollerCollectionCell", for: indexPath) as! ProfileRollerCollectionViewCell
        cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.frame.size.width/2
        cell.profilePhoto.layer.borderWidth = 0.5
        cell.profilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        
        switch collectionView.tag {
        case 0:
            let profile = self.tvPresentingArray[indexPath.row]
            cell.profileName.text = profile.name
            cell.profilePhoto.sd_setImage(with: URL(string: profile.photoUrl))
            cell.profileId.text = profile.id
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToUserDetails))
            cell.profilePhoto.isUserInteractionEnabled = true
            cell.profilePhoto.addGestureRecognizer(gestureRecognizer)
            return cell
            
        case 1:
            let profile = self.voiceOverArray[indexPath.row]
            cell.profileName.text = profile.name
            cell.profilePhoto.sd_setImage(with: URL(string: profile.photoUrl))
            cell.profileId.text = profile.id
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToUserDetails))
            cell.profilePhoto.isUserInteractionEnabled = true
            cell.profilePhoto.addGestureRecognizer(gestureRecognizer)
            return cell
            
        case 2:
            let profile = self.mcArray[indexPath.row]
            cell.profileName.text = profile.name
            cell.profilePhoto.sd_setImage(with: URL(string: profile.photoUrl))
            cell.profileId.text = profile.id
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToUserDetails))
            cell.profilePhoto.isUserInteractionEnabled = true
            cell.profilePhoto.addGestureRecognizer(gestureRecognizer)
            return cell
        
        case 3:
            let profile = self.contentCreatorArray[indexPath.row]
            cell.profileName.text = profile.name
            cell.profilePhoto.sd_setImage(with: URL(string: profile.photoUrl))
            cell.profileId.text = profile.id
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToUserDetails))
            cell.profilePhoto.isUserInteractionEnabled = true
            cell.profilePhoto.addGestureRecognizer(gestureRecognizer)
            return cell
        
        case 4:
            let profile = self.singingArray[indexPath.row]
            cell.profileName.text = profile.name
            cell.profilePhoto.sd_setImage(with: URL(string: profile.photoUrl))
            cell.profileId.text = profile.id
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToUserDetails))
            cell.profilePhoto.isUserInteractionEnabled = true
            cell.profilePhoto.addGestureRecognizer(gestureRecognizer)
            return cell
            
        default:
            let profile = self.actingArray[indexPath.row]
            cell.profileName.text = profile.name
            cell.profilePhoto.sd_setImage(with: URL(string: profile.photoUrl))
            cell.profileId.text = profile.id
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToUserDetails))
            cell.profilePhoto.isUserInteractionEnabled = true
            cell.profilePhoto.addGestureRecognizer(gestureRecognizer)
            return cell

        }

    }
    
    @objc func goToUserDetails(sender:UITapGestureRecognizer){
            let p = sender.location(in: self.tableView)
            let tableIndexPath = self.tableView.indexPathForRow(at: p)
            let tableCell = self.tableView.cellForRow(at: tableIndexPath!) as! ProfileRollerTableViewCell
            let cellCollectionView = tableCell.collectionView
            let l = sender.location(in: cellCollectionView)
            let collectionIndexPath = cellCollectionView!.indexPathForItem(at: l)
            let collectionViewCell = cellCollectionView!.cellForItem(at: collectionIndexPath!) as! ProfileRollerCollectionViewCell
            selectedID = collectionViewCell.profileId.text!

           self.performSegue(withIdentifier: "ToUserDetails", sender: nil)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

            if segue.identifier == "ToUserDetails" {
                let destinationVC = segue.destination as! UserDetailsViewController
                destinationVC.userID = self.selectedID

            }
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 76)
    }
    
}

class Profile {
    var name: String
    var photoUrl: String
    var specilization: String
    var id : String

    init(name: String, photoUrl: String, specilization : String, id : String) {
        self.name = name
        self.photoUrl = photoUrl
        self.specilization = specilization
        self.id = id
        
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}



