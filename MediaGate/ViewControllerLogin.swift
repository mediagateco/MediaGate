//
//  ViewControllerLogin.swift
//  MediaGate
//
//  Created by Nouha Nouman on 16/02/2020.
//  Copyright © 2020 Nouha Nouman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewControllerLogin: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBAction func Login(_ sender: Any) {
        if username.text != "" && password.text != "" {
            Auth.auth().signIn(withEmail: username.text!, password: password.text!) { (authdata,error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error in database", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(alert,animated: true, completion: nil)
                } else {
                    let db = Firestore.firestore()
                    //Retrieve UserID and set the FCM token to that user
                    db.collection("Users").whereField("Email", isEqualTo: self.username.text!).getDocuments { (snapshot, error) in
                    if let error = error {
                            print("Error. \(error)")
                        } else {
                            for document in snapshot!.documents {
                                //Get the user id
                                let userId = document.documentID
                                //Retrieve the FCM token
                                let deviceID = UIDevice.current.identifierForVendor!.uuidString
                                db.collection("Fcm").document(deviceID).getDocument { (snapshot, err) in
                                    if let data = snapshot?.data() {
                                        let fcmToken = data["fcmToken"]
                                        //set FCM token
                                        let fcmStore = ["fcmToken" : fcmToken!] as [String : Any]
                                        db.collection("Users").document(userId)
                                        .setData(fcmStore,merge: true)
                                    } else {
                                        print("FCM token not registered for the device")
                                    }
                                }
                            }
                        }
                    }
                    self.performSegue(withIdentifier: "ToFeedViewController", sender: nil)
                }
            }
        } else {
            let alert = UIAlertController(title: "Error in form", message: "Please enter an email or a password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginBtn.isEnabled = false
        loginBtn.alpha = 0.5
        [username, password].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        loginBtn.layer.cornerRadius = loginBtn.frame.height / 2
        username.setCirular(radius: username.frame.height / 2)
        password.setCirular(radius: password.frame.height / 2)
        username.layer.borderWidth = 1.0
        username.layer.borderColor = UIColor(red: 166/255, green: 197/255, blue: 198/255, alpha: 1.0 ).cgColor
        password.layer.borderWidth = 1.0
        password.layer.borderColor = UIColor(red: 166/255, green: 197/255, blue: 198/255, alpha: 1.0 ).cgColor
    
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let upassword = password.text, !upassword.isEmpty,
            let uusername = username.text, !uusername.isEmpty
        else {
            loginBtn.isEnabled = false
            loginBtn.alpha = 0.5
            return
        }
            loginBtn.isEnabled = true
            loginBtn.alpha = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Method to close the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Method to close the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIView {
  func setCirular(radius: CGFloat) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}
