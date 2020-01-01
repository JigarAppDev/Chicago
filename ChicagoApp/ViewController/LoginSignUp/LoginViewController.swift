//
//  LoginViewController.swift
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

class LoginViewController: UIViewController, NVActivityIndicatorViewable, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    private var toast: JYToast!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initUi()
        //self.txtEmail.becomeFirstResponder()
    }
    
    private func initUi() {
        toast = JYToast.init()
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Sign Up Click
    @IBAction func btnSignUpClick(sender: UIButton) {
        let signupVC = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
    
    //MARK: Forgot Password Click
    @IBAction func btnForgotClick(sender: UIButton) {
        let forgotVC = self.storyboard?.instantiateViewController(identifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(forgotVC, animated: true)
    }
    
    func isValidated() -> Bool {
        var isFlag = true
        if self.txtEmail.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            //self.toast.isShow("Please Enter Email!")
            DispatchQueue.main.async {
                self.showAlert(msg: "Please Enter Email!")
            }
            isFlag = false
        }else if self.txtPassword.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            //self.toast.isShow("Please Enter Password")
            DispatchQueue.main.async {
                self.showAlert(msg: "Please Enter Password")
            }
            isFlag = false
        }
        return isFlag
    }
    
    //MARK: Login Click
    @IBAction func btnLoginClick(sender: UIButton) {
        if !self.isValidated() {
            return
        }
        self.view.endEditing(true)
        self.startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let Url = String(format: APIConstants.LOGIN)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        let paramString = "email=\(self.txtEmail.text!)&password=\(self.txtPassword.text!)&device_token=123456789&device_type=ios&device_id=\(deviceId)"
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
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    //MARK: Facebook Login Click
    @IBAction func btnFBLoginClick(sender: UIButton) {
        view.endEditing(true)
         let fbLoginManager : LoginManager = LoginManager()
         fbLoginManager.logIn(permissions: ["email"], from: self, handler: { (result, error) -> Void in
             if (error == nil){
                 let fbloginresult : LoginManagerLoginResult = result!
                 if fbloginresult.isCancelled {
                    return
                 }
                 if fbloginresult.grantedPermissions != nil{
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
                                DispatchQueue.main.async {
                                    self.showAlert(msg: error?.localizedDescription ?? "Issue on facebook")
                                }
                                 fbLoginManager.logOut()
                             }
                         })
                     }else{
                         //KSToastView.ks_showToast("Issue on facebook", duration: ToastDuration)
                        DispatchQueue.main.async {
                            self.showAlert(msg: "Issue on facebook")
                        }
                     }
                 }else{
                     //KSToastView.ks_showToast("Granted permission is nil", duration: ToastDuration)
                    DispatchQueue.main.async {
                        self.showAlert(msg: "Granted permission is nil")
                    }
                 }
             }else{
                 //KSToastView.ks_showToast(error?.localizedDescription ?? "Issue on facebook", duration: ToastDuration)
                DispatchQueue.main.async {
                    self.showAlert(msg: error?.localizedDescription ?? "Issue on facebook")
                }
                 print(error?.localizedDescription ?? "")
             }
         })
        
        /*view.endEditing(true)
        let loginManager = LoginManager()
        loginManager.logOut()
        let permission = ["public_profile","email"]
        loginManager.logIn(permissions: permission, from: self) { (loginResult, error) in
            if loginResult?.isCancelled ?? false { return }
            var declinedPermissions = [String]()
            loginResult?.declinedPermissions.forEach({ (string) in
                declinedPermissions.append(string)
            })
            if declinedPermissions.count == 0 {
                _ = GraphRequest (graphPath: "me?fields=id,name,email").start(completionHandler: { (requestConnection, object, error) in
                    if error == nil {
                        let objectDetails = JSON(object!)
                        let id = objectDetails["id"].stringValue
                        let email = objectDetails["email"].stringValue
                        let name = objectDetails["name"].stringValue
                        self.loginBySocial(name: name, id: id, email: email, type: "1")
                        loginManager.logOut()
                    }else {
                        DispatchQueue.main.async {
                            self.showAlert(msg: "Permission denied")
                        }
                    }
                })
            }else {
                DispatchQueue.main.async {
                    self.showAlert(msg: "Permission denied")
                }
            }
        }*/
    }
    
    //MARK: Google Login Click
    @IBAction func btnGoogleLoginClick(sender: UIButton) {
         view.endEditing(true)
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
                            self.showAlert(msg: dataObj1["msg"].stringValue)
                        }
                    }
                    let data : JSON = JSON.init(dataObj1["info"])
                    guard let rowdata = try? data.rawData() else {return}
                    Defaults.setValue(rowdata, forKey: "userDetail")
                    Defaults.synchronize()
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    //MARK: Show Alert
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Chicago Callsheet", message:msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

