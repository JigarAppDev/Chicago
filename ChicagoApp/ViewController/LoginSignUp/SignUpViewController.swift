//
//  SignUpViewController.swift
//  ChicagoApp
//
//  Created by Vivek on 19/12/19.
//  Copyright © 2019 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import NVActivityIndicatorView

class SignUpViewController: UIViewController, NVActivityIndicatorViewable, GIDSignInDelegate, GIDSignInUIDelegate {
    
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
         let fbLoginManager : LoginManager = LoginManager()
         fbLoginManager.logIn(permissions: ["email"], from: self, handler: { (result, error) -> Void in
             if (error == nil){
                 let fbloginresult : LoginManagerLoginResult = result!
                 if fbloginresult.isCancelled {
                    return
                 }
                 if fbloginresult.grantedPermissions != nil{
                     self.tabBarController?.tabBar.isHidden = true
                     if(fbloginresult.grantedPermissions.contains("email")){
                         
                         self.startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
                         
                         //Graph data
                         let req = GraphRequest(graphPath: "me", parameters: ["fields":"email,name,first_name,last_name"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET"))
                         
                         req.start(completionHandler: { (test, result, error) in
                             if(error == nil)
                             {
                                 print(result!)
                                 let jsonUser : JSON = JSON.init(result!)
                                 self.loginBySocial(name: jsonUser["first_name"].stringValue, id: jsonUser["id"].stringValue, email: jsonUser["email"].stringValue, type: "1")
                                 fbLoginManager.logOut()
                                 
                             } else {
                                 print(error!)
                                 self.stopAnimating()
                                 //KSToastView.ks_showToast(error?.localizedDescription ?? "Issue on facebook", duration: ToastDuration)
                                self.toast.isShow(error?.localizedDescription ?? "Issue on facebook")
                                 fbLoginManager.logOut()
                             }
                         })
                     }else{
                         //KSToastView.ks_showToast("Issue on facebook", duration: ToastDuration)
                        self.toast.isShow("Issue on facebook")
                     }
                 }else{
                     //KSToastView.ks_showToast("Granted permission is nil", duration: ToastDuration)
                    self.toast.isShow("Granted permission is nil")
                 }
             }else{
                 //KSToastView.ks_showToast(error?.localizedDescription ?? "Issue on facebook", duration: ToastDuration)
                 print(error?.localizedDescription ?? "")
             }
         })
    }
    
    //MARK: Google Login Click
    @IBAction func btnGoogleLoginClick(sender: UIButton) {
         GIDSignIn.sharedInstance().delegate = self
         GIDSignIn.sharedInstance().uiDelegate = self
         GIDSignIn.sharedInstance().signIn()
    }
    
     //MARK: - Google Sign In Delegate Method
     
     func sign(_ signIn: GIDSignIn!,present viewController: UIViewController!) {
         self.present(viewController, animated: true, completion: nil)
     }
     
     func sign(_ signIn: GIDSignIn!,dismiss viewController: UIViewController!) {
         self.dismiss(animated: true, completion: nil)
     }
     
     public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
         if (error == nil) {
             
             startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
             
             let fullName : [String] = user.profile!.name.components(separatedBy: " ")
             self.loginBySocial(name: fullName[0], id: user.userID, email: user.profile.email!, type: "2")
             GIDSignIn.sharedInstance().signOut()
         } else {
             self.stopAnimating()
             print("\(error.debugDescription)")
         }
     }
     
    //MARK: Login by Social
    func loginBySocial(name:String,id:String,email:String,type:String) {
        //type 1 = fb & 2 = google
        var emailId = email
        if email == "" {
            emailId = name
        }
        self.view.endEditing(true)
        self.startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let Url = String(format: APIConstants.LoginByThirdParty)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        let paramString = "name=\(name)&thirdparty_id=\(id)&email=\(emailId)&login_type=\(type)&device_token=123456789&device_type=2&device_id=\(deviceId)"
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
                        print(dataObj1)
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Chicago Callsheet", message:dataObj1["msg"].stringValue, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    let data : JSON = JSON.init(dataObj1["info"])
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
}
