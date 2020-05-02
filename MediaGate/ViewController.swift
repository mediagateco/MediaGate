//
//  ViewController.swift
//  MediaGate
//
//  Created by Nouha Nouman on 11/02/2020.
//  Copyright © 2020 Nouha Nouman. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var registration: UIButton!
    
    @IBOutlet weak var login: UIButton!
    
    var video = AVCaptureVideoPreviewLayer()
    var inputString : String?
    var session : AVCaptureSession?
    
    @IBAction func scan(_ sender: Any) {
        
    if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
        
        //Creating a session
        session = AVCaptureSession()
        view.backgroundColor = UIColor.black
        
        //Define capture device, make sure this is also applicable to ipad's wide angle cameras
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) else {
        //guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("ERROR1: from the sanner capture session")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            self.session?.addInput(input)
        }
        catch {
            print("ERROR2: from the scanner capture session")
        }

        let output = AVCaptureMetadataOutput()
        self.session?.addOutput(output)

        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.qr]

        video = AVCaptureVideoPreviewLayer(session: self.session!)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)

        //Draw the Green square
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 150, y: 160, width: 170, height: 170), cornerRadius: 0).cgPath
        layer.strokeColor = UIColor.green.cgColor
        layer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(layer)

        //Draw the X button
        let closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(x:20, y:20, width:50, height: 50)
        closeButton.setTitleColor(.red, for: .normal)
        closeButton.setTitle("X", for: .normal)
        closeButton.layer.borderColor = UIColor.red.cgColor
        closeButton.layer.borderWidth = 1
        closeButton.layer.cornerRadius = closeButton.frame.size.height / 2.0
        closeButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        view.addSubview(closeButton)

        self.session?.startRunning()
            
            
    } else {
        presentCameraSettings()
        }
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects != nil && metadataObjects.count != nil
        {
            if let inputObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            {
                if inputObject.type == .qr
                {
                    inputString = inputObject.stringValue
                    
                    if(inputString != nil) {
                        self.session?.stopRunning()
                    
                        self.performSegue(withIdentifier: "Scan Details", sender: nil)
                    }
                }
            }
        }
    }
    
    @objc func buttonAction(_ sender:UIButton!)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyBoard.instantiateViewController(withIdentifier: "goToView") as! ViewController
        self.present(nextView, animated: true, completion: nil)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "Scan Details") {
            if let displayVC = segue.destination as? ViewControllerSignUp {
              displayVC.name = inputString
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        registration.layer.cornerRadius = registration.frame.height / 2
        login.layer.cornerRadius = login.frame.height / 2

        
    }
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "خطأ",
                                      message: "لم يتم السماح بالوصول إلى الكاميرا الخاصة بك",
                                      preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "إلغاء", style: .default))
        alertController.addAction(UIAlertAction(title: "الإعدادات", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })

        present(alertController, animated: true)
    }


}

