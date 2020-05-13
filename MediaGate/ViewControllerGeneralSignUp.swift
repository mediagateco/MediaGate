//
//  ViewControllerGeneralSignUp.swift
//  MediaGate
//
//  Created by Nouha Nouman on 02/03/2020.
//  Copyright © 2020 Nouha Nouman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class Cellclass: UITableViewCell {
    
}

class ViewControllerGeneralSignUp: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var firstView: UIView!
   
    //User Information
    @IBOutlet weak var btnCountry: UIButton!
    @IBOutlet weak var btnGender: UIButton!
    @IBOutlet weak var btnSpecilization: UIButton!
    @IBOutlet weak var lablName: UITextField!
    @IBOutlet weak var lablEmail: UITextField!
    @IBOutlet weak var lablPhoneNumber: UITextField!
    @IBOutlet weak var lablPassword: UITextField!
    @IBOutlet weak var lablPasswordConfirm: UITextField!
    
    //Corporate Information
    @IBOutlet weak var corpName: UITextField!
    @IBOutlet weak var corpReg: UITextField!
    @IBOutlet weak var corpAddress: UITextField!
    @IBOutlet weak var corpEmail: UITextField!
    @IBOutlet weak var corpPhone: UITextField!
    @IBOutlet weak var corpActivity: UITextField!
    @IBOutlet weak var corpPassword: UITextField!
    @IBOutlet weak var corpPasswordConfirm: UITextField!
    
    //Signup Buttons in each view
    @IBOutlet weak var subSignUp: UIButton!
    @IBOutlet weak var corpSignUp: UIButton!
    
    //Terms And Conditions Buttons
    @IBOutlet weak var uTermsAndConditionsSwitch: UISwitch!
    @IBOutlet weak var cTermsAndConditionsSwitch: UISwitch!
    
    let transparentView = UIView()
    let tableView = UITableView()
    var selectedButton = UIButton()
    var dataSource = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(Cellclass.self, forCellReuseIdentifier: "Cell")
        
        //Suggestion
        tableView.isScrollEnabled = true
        
        if (subSignUp != nil) {
            //Adjust the buttons with rouded corners
            subSignUp.layer.cornerRadius = subSignUp.frame.height / 2
            subSignUp.isEnabled = false
            self.subSignUp.alpha = 0.5
            btnCountry.layer.cornerRadius = btnCountry.frame.height / 2
            btnCountry.layer.borderWidth = 1.0
            btnCountry.layer.borderColor = UIColor.lightGray.cgColor
            
            
            btnGender.layer.cornerRadius = btnGender.frame.height / 2
            btnGender.layer.borderWidth = 1.0
            btnGender.layer.borderColor = UIColor.lightGray.cgColor
            btnSpecilization.layer.cornerRadius = btnSpecilization.frame.height / 2
            btnSpecilization.layer.borderWidth = 1.0
            btnSpecilization.layer.borderColor = UIColor.lightGray.cgColor
            
            //Adjust the labels
            lablName.setCorner(radius: lablName.frame.height / 2)
            lablName.layer.borderWidth = 1.0
            lablName.layer.borderColor = UIColor.lightGray.cgColor
            lablEmail.setCorner(radius: lablEmail.frame.height / 2)
            lablEmail.layer.borderWidth = 1.0
            lablEmail.layer.borderColor = UIColor.lightGray.cgColor
            lablPhoneNumber.setCorner(radius: lablPhoneNumber.frame.height / 2)
            lablPhoneNumber.layer.borderWidth = 1.0
            lablPhoneNumber.layer.borderColor = UIColor.lightGray.cgColor
            lablPassword.setCorner(radius: lablPassword.frame.height / 2)
            lablPassword.layer.borderWidth = 1.0
            lablPassword.layer.borderColor = UIColor.lightGray.cgColor
            lablPasswordConfirm.setCorner(radius: lablPasswordConfirm.frame.height / 2)
            lablPasswordConfirm.layer.borderWidth = 1.0
            lablPasswordConfirm.layer.borderColor = UIColor.lightGray.cgColor
            
            
        }
        if(lablName != nil && lablEmail != nil && lablPassword != nil && lablPasswordConfirm != nil) {
            [lablName, lablEmail,lablPhoneNumber,lablPassword,lablPasswordConfirm].forEach({ $0.addTarget(self, action: #selector(subEditingChanged), for: .editingChanged) })
        }
        
        if (corpSignUp != nil) {
            //Adjust the buttons with rouded corners
            corpSignUp.layer.cornerRadius = corpSignUp.frame.height / 2
            corpSignUp.isEnabled = false
            corpSignUp.alpha = 0.5
            btnCountry.layer.cornerRadius = btnCountry.frame.height / 2
            btnCountry.layer.borderWidth = 1.0
            btnCountry.layer.borderColor = UIColor.lightGray.cgColor
            
            //Adjust the labels
            corpName.setCorner(radius: corpName.frame.height / 2)
            corpName.layer.borderWidth = 1.0
            corpName.layer.borderColor = UIColor.lightGray.cgColor
            corpReg.setCorner(radius: corpReg.frame.height / 2)
            corpReg.layer.borderWidth = 1.0
            corpReg.layer.borderColor = UIColor.lightGray.cgColor
            corpAddress.setCorner(radius: corpAddress.frame.height / 2)
            corpAddress.layer.borderWidth = 1.0
            corpAddress.layer.borderColor = UIColor.lightGray.cgColor
            corpEmail.setCorner(radius: corpEmail.frame.height / 2)
            corpEmail.layer.borderWidth = 1.0
            corpEmail.layer.borderColor = UIColor.lightGray.cgColor
            corpPhone.setCorner(radius: corpPhone.frame.height / 2)
            corpPhone.layer.borderWidth = 1.0
            corpPhone.layer.borderColor = UIColor.lightGray.cgColor
            corpActivity.setCorner(radius: corpActivity.frame.height / 2)
            corpActivity.layer.borderWidth = 1.0
            corpActivity.layer.borderColor = UIColor.lightGray.cgColor
            corpPassword.setCorner(radius: corpPassword.frame.height / 2)
            corpPassword.layer.borderWidth = 1.0
            corpPassword.layer.borderColor = UIColor.lightGray.cgColor
            corpPasswordConfirm.setCorner(radius: corpPasswordConfirm.frame.height / 2)
            corpPasswordConfirm.layer.borderWidth = 1.0
            corpPasswordConfirm.layer.borderColor = UIColor.lightGray.cgColor
            
        }
        if (corpName != nil && corpReg != nil && corpAddress != nil && corpEmail != nil && corpPhone != nil && corpActivity != nil && corpPassword != nil && corpPasswordConfirm != nil) {
            [corpName, corpReg,corpEmail,corpPhone,corpActivity,corpPassword,corpPasswordConfirm].forEach({ $0.addTarget(self, action: #selector(corpEditingChanged), for: .editingChanged) })
        }
        
    }
    
    @objc func subEditingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let name = lablName?.text, !name.isEmpty,
            let email = lablEmail?.text, !email.isEmpty,
            let PhoneNumber = lablPhoneNumber?.text, !PhoneNumber.isEmpty,
            let Password = lablPassword?.text, !Password.isEmpty,
            let Confirm = lablPasswordConfirm?.text, !Confirm.isEmpty
        else {
            subSignUp?.isEnabled = false
            subSignUp?.alpha = 0.5
            return
        }; if(self.uTermsAndConditionsSwitch.isOn) {
            subSignUp?.isEnabled = true
            subSignUp?.alpha = 1
        }
    }
    
    @objc func corpEditingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let name = corpName?.text, !name.isEmpty,
            let reg = corpReg?.text, !reg.isEmpty,
            let address = corpAddress?.text, !address.isEmpty,
            let email = corpEmail?.text, !email.isEmpty,
            let phone = corpPhone?.text, !phone.isEmpty,
            let activity = corpActivity?.text, !activity.isEmpty,
            let password = corpPassword?.text, !password.isEmpty,
            let confirm = corpPasswordConfirm?.text, !confirm.isEmpty
        else {
            corpSignUp?.isEnabled = false
            corpSignUp?.alpha = 0.5
            return
        };
        if(self.cTermsAndConditionsSwitch.isOn) {
            corpSignUp?.isEnabled = true
            corpSignUp?.alpha = 1
        }
    }
    
    
    @IBAction func switchViews(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
                firstView.alpha = 1
            secondView?.alpha = 0
            } else {
                secondView?.alpha = 1
                firstView.alpha = 0
            }
    }
    
    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        tableView.isScrollEnabled = true
        

        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: view.frame.size.height)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5

        
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0,initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            
            //suggestion
            let m = Int(self.view.frame.height/23)
            if (self.dataSource.count > 10) {
                self.tableView.frame = CGRect(x: frames.origin.x, y: 0, width: frames.width, height: CGFloat(self.dataSource.count * (m)))
            } else {
                self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.dataSource.count * (m)))
            }
        }, completion: nil)
         
    }
    
    @objc func removeTransparentView() {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0,initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.0
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
        }, completion: nil)
    }
    
        @IBAction func onClickCountry(_ sender: Any) {
            dataSource = [
                "الامارات",
                "السعودية",
                "الأردن",
                "البحرين",
                "الجزائر",
                "العراق",
                "فلسطين",
                "الكويت",
                "تونس",
                "قطر",
                "ليبيا",
                "المغرب",
                "سوريا",
                "مصر",
                "عمان",
                "لبنان",
                "موريتانيا",
                "اليمن",
                "السودان",
                "جيبوتي",
                "جزر القمر",
    "الصومال",
"---------"
            ]
        //btnCountry.frame = CGRect(x: 100, y: -20, width: 200, height: 100)
        selectedButton = btnCountry
        addTransparentView(frames: btnCountry.frame)
    }
    
    @IBAction func onClickGender(_ sender: Any) {
        dataSource = ["لا أود أن أفصح","ذكر","أنثى"]
        selectedButton = btnGender
        addTransparentView(frames: btnGender.frame)
    }
    

    @IBAction func onClickSpecilization(_ sender: Any) {
        dataSource = [
        "تقديم تلفزيوني",
        "فويس أوفر",
        "تقديم فعاليات",
        "صناعة محتوى",
        "غناء",
        "تمثيل"
        ]
        
        selectedButton = btnSpecilization
        addTransparentView(frames: btnSpecilization.frame)
    }
    
    @IBAction func subSignUp(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        if(lablPassword.text == lablPasswordConfirm.text) {
            Auth.auth().createUser(withEmail: lablEmail.text!.trimmingCharacters(in: .whitespaces).lowercased(), password: lablPassword.text!) {
                    (authdata,error) in
                    if error != nil {
                        self.view.isUserInteractionEnabled = true
                        self.makeAlert(titleInput: "Error in database", messageInput: error!.localizedDescription)
                    } else {
                        //Retrieve the FCM token
                        let firestoreDatabase = Firestore.firestore()
                        //set FCM token
                        let fcmToken = Messaging.messaging().fcmToken
                        let fcmStore = ["fcmToken" : fcmToken!] as [String : Any]
                        //Add Database Action
                        var firestoreReference : DocumentReference? = nil
                        let firestorePost = ["Name" : self.lablName.text!,"Email" : self.lablEmail.text!.trimmingCharacters(in: .whitespaces).lowercased(), "PhoneNumber" : self.lablPhoneNumber.text!, "Nationality" : self.btnCountry.titleLabel?.text!,"Specialization" : self.btnSpecilization.titleLabel?.text!,"Gender" : self.btnGender.titleLabel?.text!,"isVerified" : false, "isCompany" : false , "isTrainer" : false , "Description" : "", "Registration Number" : "", "Address" : "", "Activity" : "", "fcmToken" : fcmToken] as [String : Any]
                        firestoreReference = firestoreDatabase.collection("Users").addDocument(data: firestorePost, completion: { (error) in
                                if error != nil {
                                        self.view.isUserInteractionEnabled = true
                                        self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                                    } else {
                                        //CONFIRMATION
                                        print("User Created Successfully")
                                        self.view.isUserInteractionEnabled = true
                                        let alert = UIAlertController(title: "مبروك!", message: "مبروك لانضمامك معنا لعائلة ميدياغيت!",preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title:"متابعة", style: .default, handler:  { action in self.performSegue(withIdentifier: "sendToFeed2", sender: nil)
                                        } ))
                                        self.present(alert,animated: true, completion: nil)
                                    }
                                })
                        
                }}}
            else {
                self.view.isUserInteractionEnabled = true
                self.makeAlert(titleInput: "خطأ!", messageInput: "هنالك خطأ في انشاء كلمة المرور. الرجاء التأكد من أن كلمة المرور في الحقلين هي ذاتها.")
            }
    }
    
    @IBAction func corpSignUp(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        if(corpPassword.text == corpPasswordConfirm.text) {
            Auth.auth().createUser(withEmail: corpEmail.text!.trimmingCharacters(in: .whitespaces).lowercased(), password: corpPassword.text!) {
                (authdata,error) in
                if error != nil {
                    self.view.isUserInteractionEnabled = true
                    self.makeAlert(titleInput: "Error in database!", messageInput: error!.localizedDescription)
                } else {
                    //Add to Database
                    //Retrieve the FCM token
                    let firestoreDatabase = Firestore.firestore()
                    let fcmToken = Messaging.messaging().fcmToken
                    //set FCM token
                    let fcmStore = ["fcmToken" : fcmToken!] as [String : Any]
                    //Add Database Action
                    var firestoreReference : DocumentReference? = nil
                    let firestorePost = ["Name" : self.corpName.text!,"Email" : self.corpEmail.text!.trimmingCharacters(in: .whitespaces).lowercased(), "PhoneNumber" : self.corpPhone.text!, "Nationality" : self.btnCountry.titleLabel?.text!,"Specialization" : "","Gender" : "","isVerified" : false, "isCompany" : true , "isTrainer" : false , "Description" : "", "Registration Number" : self.corpReg.text!, "Address" : self.corpAddress.text!, "Activity" : self.corpActivity.text!, "fcmToken" : fcmToken] as [String : Any]
                    firestoreReference = firestoreDatabase.collection("Users").addDocument(data: firestorePost, completion:
                    { (error) in
                        if error != nil {
                                    self.view.isUserInteractionEnabled = true
                                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                                } else {
                                    //CONFIRMATION
                                    self.view.isUserInteractionEnabled = true
                                    print("User Created Successfully")
                                    let alert = UIAlertController(title: "مبروك!", message: "مبروك لانضمامك معنا لعائلة ميدياغيت!",preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title:"متابعة", style: .default, handler:  { action in self.performSegue(withIdentifier: "sendToFeed3", sender: nil)
                                    } ))
                                    self.present(alert,animated: true, completion: nil)
                                }
                            })
                    
                }}}
            else {
                self.view.isUserInteractionEnabled = true
                self.makeAlert(titleInput: "خطأ!", messageInput: "هنالك خطأ في انشاء كلمة المرور. الرجاء التأكد من أن كلمة المرور في الحقلين هي ذاتها.")
        }
        
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func termsAndConditionsClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "GoToTermsAndConditions", sender: nil)
    }
    
    @IBAction func uIagree(_ sender: Any) {
        if (uTermsAndConditionsSwitch.isOn == false) {
            self.subSignUp.isEnabled = false
            self.subSignUp.alpha = 0.5
            
        } else {
            if (lablName.text != "" && lablPhoneNumber.text != "" && lablEmail.text != "" && lablPassword.text != "" && lablPasswordConfirm.text != "") {
                self.subSignUp.isEnabled = true
                self.subSignUp.alpha = 1
            }
        }
    }

    @IBAction func cIagree(_ sender: Any) {
        if (cTermsAndConditionsSwitch.isOn == false) {
                    self.corpSignUp.isEnabled = false
                    self.corpSignUp.alpha = 0.5
                    
                } else {
            if (corpName.text != "" && corpReg.text != "" && corpActivity.text != "" && corpEmail.text != "" && corpPhone.text != "" && corpPassword.text != "" && corpPasswordConfirm.text != "") {
                        self.corpSignUp.isEnabled = true
                        self.corpSignUp.alpha = 1
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

extension ViewControllerGeneralSignUp: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
       }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableView.automaticDimension
        //return 50
        return view.frame.height/23
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
        removeTransparentView()
    }
   
}


extension UIView {
  func setCorner(radius: CGFloat) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}

extension UITextField {
    enum ViewType {
        case left, right
    }
    
    // (1)
    func setView(_ type: ViewType, with view: UIView) {
        if type == ViewType.left {
            leftView = view
            leftViewMode = .always
        } else if type == .right {
            rightView = view
            rightViewMode = .always
        }
    }
}


