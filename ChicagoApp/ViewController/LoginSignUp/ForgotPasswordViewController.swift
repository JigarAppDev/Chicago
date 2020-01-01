//
//  ForgotPasswordViewController.swift
//  ChicagoApp
//
//  Created by Vivek on 19/12/19.
//  Copyright © 2019 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class ForgotPasswordViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet var txtEmail: UITextField!
    var toast: JYToast!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.toast = JYToast.init()
        //self.txtEmail.becomeFirstResponder()
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func isValidated() -> Bool {
        var isFlag = true
        if self.txtEmail.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            self.toast.isShow("Please Enter Email!")
            isFlag = false
        }
        return isFlag
    }
    
    //MARK: Submit Click
    @IBAction func btnSubmitClick(sender: UIButton) {
        if !self.isValidated() {
            return
        }
        self.view.endEditing(true)
        self.startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let Url = String(format: APIConstants.FORGOTPWD)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        let paramString = "email=\(self.txtEmail.text!)"
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
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Chicago Callsheet", message:dataObj1["msg"].stringValue, preferredStyle: .alert)
                        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
                            if dataObj1["status_code"].boolValue == true {
                                let resetVC = self.storyboard?.instantiateViewController(identifier: "ResetPasswordViewController") as! ResetPasswordViewController
                                resetVC.email = self.txtEmail.text!
                                self.navigationController?.pushViewController(resetVC, animated: true)
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}
