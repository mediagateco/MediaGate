//
//  ViewControllerSignUp.swift
//  MediaGate
//
//  Created by Nouha Nouman on 13/02/2020.
//  Copyright © 2020 Nouha Nouman. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore



class ViewControllerSignUp: UIViewController, UITextFieldDelegate {
    
    var name: String?
    var studentName: String?
    var studentEmail: String?
    var studentPhone: String?
    var studentNationality: String?
    var studentSpecialization: String?
    var studentGender: String?
    var studentPassword: String?

    @IBOutlet weak var studentNameField: UILabel!
    @IBOutlet weak var studentEmailField: UILabel!
    @IBOutlet weak var studentPhoneField: UILabel!
    @IBOutlet weak var studentNationalityField: UILabel!
    @IBOutlet weak var studentSpecializationField: UILabel!
    
    @IBOutlet weak var studentPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var Iagree: UISwitch!
    @IBOutlet weak var signUp: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDetailsArr = name?.components(separatedBy: "،")
        // Do any additional setup after loading the view.
        if (userDetailsArr != nil) {
            studentName = userDetailsArr![0]
            studentEmail = userDetailsArr![1].trimmingCharacters(in: .whitespaces).lowercased()
            studentPhone = userDetailsArr![2]
            studentNationality = userDetailsArr![3]
            studentSpecialization = userDetailsArr![4]
            studentGender = userDetailsArr![5]
        }
        
        studentNameField.text = studentName
        studentEmailField.text = studentEmail
        studentPhoneField.text = studentPhone
        studentNationalityField.text = studentNationality
        studentSpecializationField.text = studentSpecialization
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        signUp.isEnabled = false
        signUp.alpha = 0.5
        [studentPasswordField, confirmPasswordField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        
        //setup the rounded corners for the signup buttons and textfields
        signUp.layer.cornerRadius = signUp.frame.height / 2
        studentPasswordField.setRounded(radius: studentPasswordField.frame.height / 2)
        studentPasswordField.layer.borderWidth = 1.0
        studentPasswordField.layer.borderColor = UIColor.lightGray.cgColor
        confirmPasswordField.setRounded(radius: confirmPasswordField.frame.height / 2)
        confirmPasswordField.layer.borderWidth = 1.0
        confirmPasswordField.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let password = studentPasswordField.text, !password.isEmpty,
            let confirm = confirmPasswordField.text, !confirm.isEmpty
        else {
            signUp.isEnabled = false
            signUp.alpha = 0.5
            return
        };
        if(self.Iagree.isOn) {
            signUp.isEnabled = true
            signUp.alpha = 1
        }
        
    }
    
    @IBAction func agree(_ sender: Any) {
        if (Iagree.isOn == false) {
            self.signUp.isEnabled = false
            self.signUp.alpha = 0.5
            
        } else {
            if (studentPasswordField.text != "" && confirmPasswordField.text != "") {
                self.signUp.isEnabled = true
                self.signUp.alpha = 1
            }
        }
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        if(self.studentPasswordField.text == self.confirmPasswordField.text) {
            Auth.auth().createUser(withEmail: studentEmail!.lowercased(), password: studentPasswordField.text!) {
                (authdata,error) in
                if error != nil {
                    self.view.isUserInteractionEnabled = true
                    self.makeAlert(titleInput: "Error in Database!", messageInput: error!.localizedDescription)
                } else {
                        //Add Database Action
                        //Retrieve the FCM token
                        let firestoreDatabase = Firestore.firestore()
                        let deviceID = UIDevice.current.identifierForVendor!.uuidString
                        firestoreDatabase.collection("Fcm").document(deviceID).getDocument
                        { (snapshot, err) in
                            if let data = snapshot?.data() {
                                let fcmToken = data["fcmToken"]
                                //set FCM token
                                let fcmStore = ["fcmToken" : fcmToken!] as [String : Any]
                                //Add Database Action
                                //let firestoreDatabase = Firestore.firestore()
                                var firestoreReference : DocumentReference? = nil
                                let firestorePost = ["Name" : self.studentName!,"Email" : self.studentEmail!.lowercased(), "PhoneNumber" : self.studentPhone!, "Nationality" : self.studentNationality!,"Specialization" : self.studentSpecialization!,"Gender" : self.studentGender!,"isVerified" : true, "isCompany" : false , "isTrainer" : false , "Description" : "", "Registration Number" : "", "Address" : "", "Activity" : "", "fcmToken" : fcmToken] as [String : Any]
                                firestoreReference = firestoreDatabase.collection("Users").addDocument(data: firestorePost, completion: { (error) in
                                    if error != nil {
                                        self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                                        //delete the created User in Authentication
                                        //let userID = Auth.auth().currentUser!.uid
                                        let user = Auth.auth().currentUser
                                        //user?.delete { error in
                                          //if let error = error {
                                            // An error happened.
                                          //} else {
                                            // Account deleted.
                                          //}
                                        //}
                                    } else {
                                        //CONFIRMATION
                                        self.view.isUserInteractionEnabled = true
                                        print("User Created Successfully")
                                        let alert = UIAlertController(title: "مبروك!", message: "مبروك لانضمامك معنا لعائلة ميدياغيت!",preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title:"متابعة", style: .default, handler:  { action in self.performSegue(withIdentifier: "SendToFeed", sender: nil)
                                        } ))
                                        self.present(alert,animated: true, completion: nil)
                                        //SEND VERIFICATION EMAIL
                                        //self.sendEmailVerification()
                                        }})
                            } else {
                                self.view.isUserInteractionEnabled = true
                                print("FCM token not registered for the device")
                        }
                            
                    }}}}else {
                            self.view.isUserInteractionEnabled = true
                            self.makeAlert(titleInput: "خطأ!", messageInput: "هنالك خطأ في انشاء كلمة المرور. الرجاء التأكد من أن كلمة المرور في الحقلين هي ذاتها.")
                        }
    }
    
    func sendEmailVerification(_ callback: ((Error?) -> ())? = nil){
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            callback?(error)
        })
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
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle:
            UIAlertController.Style.alert)
        let okButton = UIAlertAction(title:"Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func backToMV(_ sender: Any) {
        self.performSegue(withIdentifier: "BackToMainVC", sender: nil)
    }
    
    
    @IBAction func checkTermsAndConditions(_ sender: Any) {
        self.performSegue(withIdentifier: "TermsConditionsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "TermsConditionsVC") {
            if let displayVC = segue.destination as? ViewControllerTermsConditions {
                displayVC.name = self.name
            }
            
        }
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

extension UIView {
  func setRounded(radius: CGFloat) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}
