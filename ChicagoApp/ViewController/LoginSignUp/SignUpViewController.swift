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
    private var toast: JYToast!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initUi()
        self.txtFullname.becomeFirstResponder()
    }
        
    private func initUi() {
        toast = JYToast.init()
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Login Click
    @IBAction func btnLoginClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func isValidated() -> Bool {
        var isFlag = true
        if self.txtFullname.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            self.toast.isShow("Please Enter Your Fullname!")
            isFlag = false
        }else if self.txtEmail.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            self.toast.isShow("Please Enter Your Email!")
            isFlag = false
        }else if self.txtPassword.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            self.toast.isShow("Please Enter Your Password!")
            isFlag = false
        }else if self.txtConfirmPassword.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            self.toast.isShow("Please Enter Your Confirm Password!")
            isFlag = false
        }else if self.txtPassword.text! != self.txtConfirmPassword.text! {
            self.toast.isShow("Your password is mismatch!")
            isFlag = false
        }
        return isFlag
    }
    
    //MARK: Sign Up Click
    @IBAction func btnSignUpClick(sender: UIButton) {
        if !self.isValidated() {
            return
        }
        self.view.endEditing(true)
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
            DispatchQueue.main.async {
                self.stopAnimating()
            }
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
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Chicago Callsheet", message:dataObj1["msg"].stringValue, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    let data : JSON = JSON.init(dataObj1["data"])
                    guard let rowdata = try? data.rawData() else {return}
                    Defaults.setValue(rowdata, forKey: "userDetail")
                    Defaults.synchronize()
                    DispatchQueue.main.async {
                        for vw in self.navigationController!.viewControllers {
                            if vw.isKind(of: HomeViewController.classForCoder()) {
                                self.navigationController?.popToViewController(vw, animated: true)
                            }
                        }
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
