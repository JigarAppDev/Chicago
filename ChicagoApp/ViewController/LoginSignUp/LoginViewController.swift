//
//  LoginViewController.swift
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

class LoginViewController: UIViewController, NVActivityIndicatorViewable { // GIDSignInDelegate, GIDSignInUIDelegate,

    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    private var toast: JYToast!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initUi()
    }
    
    private func initUi() {
        toast = JYToast()
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
            self.toast.isShow("Please Enter Email!")
            isFlag = false
        }else if self.txtPassword.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            self.toast.isShow("Please Enter Password")
            isFlag = false
        }
        return isFlag
    }
    
    //MARK: Login Click
    @IBAction func btnLoginClick(sender: UIButton) {
        if !self.isValidated() {
            return
        }
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
                    //self.toast.isShow(dataObj1["msg"].stringValue)
                    if dataObj1["status_code"].intValue == 1 {
                        print(dataObj1)
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
        /*
         let fbLoginManager : LoginManager = LoginManager()
         fbLoginManager.logIn(permissions: ["email"], from: self, handler: { (result, error) -> Void in
             print(result?.isCancelled)
             print(result)
             print(error)
             if (error == nil){
                 let fbloginresult : LoginManagerLoginResult = result!
                 self.tabBarController?.tabBar.isHidden = true
                 if fbloginresult.grantedPermissions != nil{
                     self.tabBarController?.tabBar.isHidden = true
                     if(fbloginresult.grantedPermissions.contains("email")){
                         
                         //let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                         
                         self.startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
                         
                         //Graph data
                         let req = GraphRequest(graphPath: "me", parameters: ["fields":"email,name,first_name,last_name"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET"))
                         
                         req.start(completionHandler: { (test, result, error) in
                             if(error == nil)
                             {
                                 print(result!)
                                 let jsonUser : JSON = JSON.init(result!)
                                 let param  : NSMutableDictionary =  NSMutableDictionary()
                                 param.setValue("", forKey: "google_id")
                                 param.setValue(jsonUser["id"].stringValue, forKey: "facebook_id")
                                 let randomInt = Int.random(in: 0..<1000)
                                 if jsonUser["first_name"].stringValue != "" {
                                     param.setValue("\(jsonUser["first_name"].stringValue)\(randomInt)", forKey: "username")
                                 } else {
                                     param.setValue(jsonUser["name"].stringValue, forKey: "username")
                                 }
                                 param.setValue(jsonUser["first_name"].stringValue, forKey: "first_name")
                                 param.setValue(jsonUser["last_name"].stringValue, forKey: "last_name")
                                 param.setValue(jsonUser["email"].stringValue, forKey: "email")
                                 if isHire {
                                     param.setValue("2", forKey: "profile_type_id")
                                 } else {
                                     param.setValue("1", forKey: "profile_type_id")
                                 }
                                 param.setValue(deviceTokenClientGL, forKey: "device_token")
                                 param.setValue("0", forKey: "device_type") //0 -> iOS 1-> Android
                                 self.sendSocial(param: param)
                                 fbLoginManager.logOut()
                                 
                             } else {
                                 print(error!)
                                 self.stopAnimating()
                                 KSToastView.ks_showToast(error?.localizedDescription ?? "Issue on facebook", duration: ToastDuration)
                                 fbLoginManager.logOut()
                             }
                         })
                         
                         /*Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                             if error != nil {
                                 print(error!)
                                 self.stopAnimating()
                                 KSToastView.ks_showToast(error?.localizedDescription ?? "Issue on facebook", duration: ToastDuration)
                                 fbLoginManager.logOut()
                             }else{
                                 let jsonUser : JSON = JSON.init(authResult!.additionalUserInfo!.profile!)
                                 //KSToastView.ks_showToast(jsonUser, duration: ToastDuration)
                                 let param  : NSMutableDictionary =  NSMutableDictionary()
                                 param.setValue("", forKey: "google_id")
                                 param.setValue(Auth.auth().currentUser!.uid, forKey: "facebook_id")
                                 let randomInt = Int.random(in: 0..<1000)
                                 if jsonUser["name"].stringValue != "" {
                                     param.setValue("\(jsonUser["name"].stringValue)\(randomInt)", forKey: "username")
                                 }
                                 param.setValue(jsonUser["name"].stringValue, forKey: "username")
                                 param.setValue(jsonUser["first_name"].stringValue, forKey: "first_name")
                                 param.setValue(jsonUser["last_name"].stringValue, forKey: "last_name")
                                 param.setValue(jsonUser["email"].stringValue, forKey: "email")
                                 if isHire {
                                     param.setValue("2", forKey: "profile_type_id")
                                 } else {
                                     param.setValue("1", forKey: "profile_type_id")
                                 }
                                 param.setValue(deviceTokenGL, forKey: "device_token")
                                 param.setValue("0", forKey: "device_type") //0 -> iOS 1-> Android
                                 self.sendSocial(param: param)
                                 fbLoginManager.logOut()
                             }
                         }*/
                     }else{
                         KSToastView.ks_showToast("Issue on facebook", duration: ToastDuration)
                     }
                 }else{
                     KSToastView.ks_showToast("Granted permission is nil", duration: ToastDuration)
                 }
             }else{
                 KSToastView.ks_showToast(error?.localizedDescription ?? "Issue on facebook", duration: ToastDuration)
                 print(error?.localizedDescription ?? "")
             }
         })
         */
    }
    
    //MARK: Google Login Click
    @IBAction func btnGoogleLoginClick(sender: UIButton) {
        /*
         GIDSignIn.sharedInstance().delegate = self
         GIDSignIn.sharedInstance().uiDelegate = self
         GIDSignIn.sharedInstance().signIn()
         */
    }
    
    /*
     //MARK: - Google Sign In Delegate Method
     
     func sign(_ signIn: GIDSignIn!,present viewController: UIViewController!) {
         self.present(viewController, animated: true, completion: nil)
     }
     
     func sign(_ signIn: GIDSignIn!,dismiss viewController: UIViewController!) {
         self.dismiss(animated: true, completion: nil)
     }
     
     public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
         if (error == nil) {
             
             /*guard let authentication = user.authentication else { return }
             let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                            accessToken: authentication.accessToken)*/
             
             startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
             
             let fullName : [String] = user.profile!.name.components(separatedBy: " ")
             let param  : NSMutableDictionary =  NSMutableDictionary()
             param.setValue(user.userID, forKey: "google_id")
             param.setValue("", forKey: "facebook_id")
             let randomInt = Int.random(in: 0..<1000)
             if user.profile!.name != nil {
                 param.setValue("\(fullName[0])\(randomInt)", forKey: "username")
             }
             param.setValue(fullName[0], forKey: "first_name")
             param.setValue(fullName[1], forKey: "last_name")
             param.setValue(user.profile.email!, forKey: "email")
             if isHire {
                 param.setValue("2", forKey: "profile_type_id")
             } else {
                 param.setValue("1", forKey: "profile_type_id")
             }
             param.setValue(deviceTokenClientGL, forKey: "device_token")
             param.setValue("0", forKey: "device_type") //0 -> iOS 1-> Android
             self.sendSocial(param: param)
             GIDSignIn.sharedInstance().signOut()
             
             /*Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                 if let error = error {
                     self.stopAnimating()
                     KSToastView.ks_showToast("\(error)", duration: ToastDuration)
                     return
                 }else{
                     KSToastView.ks_showToast("\(user.profile.email!)", duration: ToastDuration)
                     let fullName : [String] = user.profile!.name.components(separatedBy: " ")
                     let param  : NSMutableDictionary =  NSMutableDictionary()
                     param.setValue(Auth.auth().currentUser!.uid, forKey: "google_id")
                     param.setValue("", forKey: "facebook_id")
                     let randomInt = Int.random(in: 0..<1000)
                     if user.profile!.name != nil {
                         param.setValue("\(fullName[0])\(randomInt)", forKey: "username")
                     }
                     param.setValue(fullName[0], forKey: "first_name")
                     param.setValue(fullName[1], forKey: "last_name")
                     param.setValue(user.profile.email!, forKey: "email")
                     if isHire {
                         param.setValue("2", forKey: "profile_type_id")
                     } else {
                         param.setValue("1", forKey: "profile_type_id")
                     }
                     param.setValue(deviceTokenGL, forKey: "device_token")
                     param.setValue("0", forKey: "device_type") //0 -> iOS 1-> Android
                     self.sendSocial(param: param)
                     GIDSignIn.sharedInstance().signOut()
                 }
             }*/
         } else {
             self.stopAnimating()
             print("\(error.debugDescription)")
         }
     }
     */
}
