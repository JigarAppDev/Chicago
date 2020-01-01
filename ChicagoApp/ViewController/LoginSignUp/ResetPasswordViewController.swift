//
//  ResetPasswordViewController.swift
//  ChicagoApp
//
//  Created by Vivek on 19/12/19.
//  Copyright © 2019 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class ResetPasswordViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var txtOTP: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var txtConfirmPassword: UITextField!
    var toast: JYToast!
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.toast = JYToast.init()
        //self.txtOTP.becomeFirstResponder()
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func isValidated() -> Bool {
        var isFlag = true
        if self.txtOTP.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            self.toast.isShow("Please Enter OTP!")
            isFlag = false
        }else if self.txtPassword.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            self.toast.isShow("Please Enter Password")
            isFlag = false
        }else if self.txtConfirmPassword.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            self.toast.isShow("Please Enter Confirm Password")
            isFlag = false
        }
        return isFlag
    }
    
    //MARK: Reset Click
    @IBAction func btnResetNow(sender: UIButton) {
        if !self.isValidated() {
            return
        }
        self.view.endEditing(true)
        self.startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let Url = String(format: APIConstants.RESETPWD)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        let paramString = "email=\(self.email)&temp_password=\(self.txtOTP.text!)&new_password=\(self.txtPassword.text!)"
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
                    if dataObj.value(forKey: "status_code") as! Int == 1 {
                        print(dataObj)
                    }
                    let dataObj1 = JSON.init(json)
                    if dataObj1["status_code"].intValue == 1 {
                        DispatchQueue.main.async {
                            for vw in self.navigationController!.viewControllers {
                                if vw.isKind(of: LoginViewController.classForCoder()) {
                                    self.navigationController?.popToViewController(vw, animated: true)
                                }
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    //MARK: Resend OTP
    @IBAction func btnResendOTP(sender: UIButton) {
        self.startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let Url = String(format: APIConstants.FORGOTPWD)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        let paramString = "email=\(self.email)"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            self.stopAnimating()
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let dataObj = json as! NSDictionary
                    if dataObj.value(forKey: "status_code") as! Int == 1 {
                        print(dataObj)
                    }
                    let dataObj1 = JSON.init(json)
                    if dataObj1["status_code"].intValue == 1 {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Chicago Callsheet", message: "OTP sent to your email box!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Chicago Callsheet", message:dataObj1["msg"].stringValue, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}
