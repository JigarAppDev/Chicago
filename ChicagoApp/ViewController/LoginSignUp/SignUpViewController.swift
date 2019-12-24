//
//  SignUpViewController.swift
//  ChicagoApp
//
//  Created by Vivek on 19/12/19.
//  Copyright © 2019 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON
import KSToastView
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import NVActivityIndicatorView

class SignUpViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet var txtFullname: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var txtConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Login Click
    @IBAction func btnLoginClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Sign Up Click
    @IBAction func btnSignUpClick(sender: UIButton) {
        if self.txtFullname.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            KSToastView.ks_showToast("Please Enter Your Fullname!", duration: ToastDuration)
            return
        }else if self.txtEmail.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            KSToastView.ks_showToast("Please Enter Your Email!", duration: ToastDuration)
            return
        }else if self.txtPassword.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            KSToastView.ks_showToast("Please Enter Your Password!", duration: ToastDuration)
            return
        }else if self.txtConfirmPassword.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            KSToastView.ks_showToast("Please Enter Your Confirm Password!", duration: ToastDuration)
            return
        }else if self.txtPassword.text! != self.txtConfirmPassword.text! {
            KSToastView.ks_showToast("Your password is mismatch!", duration: ToastDuration)
            return
        }
        self.startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let Url = String(format: APIConstants.SIGNUP)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        let paramString = "name=\(self.txtFullname.text!)&email=\(self.txtEmail.text!)&password=\(self.txtPassword.text!)&device_token=123456789&device_type=ios&device_id=\(deviceId)"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            self.dismiss(animated: true, completion: nil)
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let dataObj = json as! NSDictionary
                    if dataObj.value(forKey: "status_code") as! Bool == true {
                        print(dataObj)
                    }
                    let dataObj1 = JSON.init(json)
                    if dataObj1["status_code"].boolValue == true {
                        print(dataObj1)
                    }
                    DispatchQueue.main.async {
                        //self.tblMainCat.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    //MARK: Facebook Login Click
    @IBAction func btnFBLoginClick(sender: UIButton) {
        
    }
    
    //MARK: Google Login Click
    @IBAction func btnGoogleLoginClick(sender: UIButton) {
        
    }
}
