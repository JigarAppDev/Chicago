//
//  AddShopViewController.swift
//  ChicagoApp
//
//  Created by Vivek on 23/12/19.
//  Copyright © 2019 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation

class AddShopViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NVActivityIndicatorViewable, SBPickerSelectorDelegate {
    
    @IBOutlet var shopImage: UIImageView!
    @IBOutlet var btnAddImage: UIButton!
    @IBOutlet var txtShopname: UITextField!
    @IBOutlet var txvAbout: UITextView!
    @IBOutlet var txtLocation: UITextField!
    @IBOutlet var txtMobile: UITextField!
    @IBOutlet var txtClientSubmission: UITextField!
    @IBOutlet var txtWebSite: UITextField!
    @IBOutlet var txtCategory: UITextField!
    var selectedCatId = ""
    var ArrUploadFile = NSMutableArray()
    private var toast: JYToast!
    var lati = 0.0
    var longi = 0.0
    var arrAllCategory = [JSON]()
    var catArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUi()
        self.txtShopname.setLeftPaddingPoints(5)
        self.txtCategory.setLeftPaddingPoints(5)
        self.txtLocation.setLeftPaddingPoints(5)
        self.txtWebSite.setLeftPaddingPoints(5)
        self.txtClientSubmission.setLeftPaddingPoints(5)
        self.txtMobile.setLeftPaddingPoints(5)
        
        self.getAllSubCategory()
    }
    
    private func initUi() {
        toast = JYToast.init()
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getAllSubCategory() {
        let Url = String(format: APIConstants.GetAllSubCategory)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        //let paramString = "parent_category=0"
        //request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
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
                        self.arrAllCategory.removeAll()
                        self.arrAllCategory = dataObj1["info"].arrayValue
                    }
                    if self.arrAllCategory.count > 0 {
                        self.catArray = [String]()
                        for obj in self.arrAllCategory {
                            self.catArray.append(obj["category_name"].stringValue)
                        }
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
    
    func isValidated() -> Bool {
        var isFlag = true
        if self.ArrUploadFile.count == 0 {
            //self.toast.isShow("Please Add Shop Logo!")
            DispatchQueue.main.async {
                self.showAlert(msg: "Please Add Shop Logo/Image!")
            }
            isFlag = false
        } else if self.txtShopname.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            //self.toast.isShow("Please Enter Shopname!")
            DispatchQueue.main.async {
                self.showAlert(msg: "Please Enter Shopname!")
            }
            isFlag = false
        } else if self.txtCategory.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            DispatchQueue.main.async {
                self.showAlert(msg: "Please Select Category!")
            }
            isFlag = false
        } else if self.txvAbout.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            //self.toast.isShow("Please Enter About Info!")
            DispatchQueue.main.async {
                self.showAlert(msg: "Please Enter About Info!")
            }
            isFlag = false
        } else if self.txtLocation.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            //self.toast.isShow("Please Enter Location!")
            DispatchQueue.main.async {
                self.showAlert(msg: "Please Enter Your Full Address!")
            }
            isFlag = false
        } else if self.txtMobile.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            //self.toast.isShow("Please Enter Mobile Number!")
            DispatchQueue.main.async {
                self.showAlert(msg: "Please Enter Mobile Number!")
            }
            isFlag = false
        } else if self.txtClientSubmission.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            //self.toast.isShow("Please Enter Email!")
            DispatchQueue.main.async {
                self.showAlert(msg: "Please Enter Submission Link!")
            }
            isFlag = false
        } else if self.txtWebSite.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            DispatchQueue.main.async {
                self.showAlert(msg: "Please Enter Website Url!")
            }
            isFlag = false
        }
        return isFlag
    }
    
    //MARK: Select Category
    @IBAction func btnSelectCategory(sender: UIButton) {
        self.view.endEditing(true)
        let picker = SBPickerSelector()
        picker.tag = 101
        picker.delegate = self
        picker.pickerType = SBPickerSelectorType.text
        picker.pickerData = self.catArray
        picker.doneButtonTitle = "Done"
        picker.cancelButtonTitle = "Cancel"
        picker.doneButton?.tintColor = .white
        picker.cancelButton?.tintColor = .white
        picker.pickerView.backgroundColor = .white
        //picker.pickerView.setValue(UIColor.black, forKeyPath: "textColor")
        picker.optionsToolBar?.barTintColor = UIColor(red: 85/255, green: 80/255, blue: 238/255, alpha: 1.0)
        picker.showPickerOver(self)
    }
    
    //MARK:- Picker delegate methods
    func pickerSelector(_ selector: SBPickerSelector, selectedValues values: [String], atIndexes idxs: [NSNumber]) {
        if selector.tag == 101 {
            self.txtCategory.text = values[0]
            let arr = self.arrAllCategory.filter { (obj) -> Bool in
                obj["category_name"].stringValue == values[0]
            }
            if arr.count > 0 {
                self.selectedCatId = arr[0]["category_id"].stringValue
            }
        }
    }
    
    //MARK: Submit Click
    @IBAction func btnSubmitClick(sender: UIButton) {
        if !self.isValidated() {
            return
        }
        self.view.endEditing(true)
        var userId = ""
        if let userObj = Defaults.value(forKey: "userDetail") {
            userId = JSON.init(userObj)["user_id"].stringValue
        } else {
            self.showAlert(msg: "Please login to add shop!")
            return
        }
        self.startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let Url = String(format: APIConstants.ADDSHOP)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        
        //let paramString = "shop_name=\(self.txtShopname.text!)&about=\(self.txvAbout.text!)&location=\(self.txtLocation.text!)&mobile_number=\(self.txtMobile.text!)&email=\(self.txtEmail.text!)&latitude=\(self.lati)&longitude=\(self.longi)"
        //request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let paramString = [ "user_id":userId,"company_name":self.txtShopname.text!,"category_id":self.selectedCatId,"three_sentence_summary":self.txvAbout.text!,"address":self.txtLocation.text!,"phone":self.txtMobile.text!,"client_Subbmission_link":self.txtClientSubmission.text!,"website":self.txtWebSite.text!] as [String : Any]
        
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let imageData = self.ArrUploadFile[0]
        request.httpBody = createBodyWithParameters(parameters: paramString as? [String : String], filePathKey: "profile_pic", imageDataKey: imageData as! NSData, boundary: boundary) as Data
        
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
                            if dataObj1["status_code"].intValue == 1 {
                                self.navigationController?.popViewController(animated: true)
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
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string:"--\(boundary)\r\n")
                body.appendString(string:"Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string:"\(value)\r\n")
            }
        }
        
        let filename = "shopimage.jpg"
        let mimetype = "image/jpg"
        body.appendString(string:"--\(boundary)\r\n")
        body.appendString(string:"Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string:"Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string:"\r\n")
        body.appendString(string:"--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    //MARK: Select Image
    @IBAction func btnAddImage(sender : UIButton){
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "Add Image", message: "Select your option!", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Camera", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                let imag = UIImagePickerController()
                imag.delegate = self
                imag.sourceType = UIImagePickerController.SourceType.camera;
                //imag.mediaTypes = [kUTTypeImage as String]
                imag.allowsEditing = false
                self.present(imag, animated: true, completion: nil)
            } else {
                //KSToastView.ks_showToast("Device has no camera!", duration: ToastDuration)
            }
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Library", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                let imag = UIImagePickerController()
                imag.delegate = self
                imag.sourceType = UIImagePickerController.SourceType.photoLibrary
                //imag.mediaTypes = [kUTTypeImage as String]
                imag.allowsEditing = false
                self.present(imag, animated: true, completion: nil)
            }
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    
    //MARK: - Image Picker Delegate Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.shopImage.image = tempImage
        guard let imageData = tempImage.jpegData(compressionQuality: 0.75) else { return }
        ArrUploadFile.add(imageData)
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Get Lat Long From Address
    func getAddress() {
        startAnimating(Loadersize, message: "", type: NVActivityIndicatorType.ballSpinFadeLoader)
        let location: String = self.txtLocation.text!
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.geocodeAddressString(location, completionHandler: {(placemarks: [CLPlacemark]?, error: Error?) -> Void in
            self.stopAnimating()
            //If no data
            if placemarks == nil {
                //KSToastView.ks_showToast("Please Enter Valid ZipCode!", duration: ToastDuration)
                return
            }
            if ((placemarks?.count)! > 0) {
                let placemark: CLPlacemark = (placemarks?[0])!
                //let country : String = placemark.country!
                //let state: String = placemark.administrativeArea!
                //let city = placemark.locality!
                self.lati = Double((placemark.location?.coordinate.latitude)!)
                self.longi = Double((placemark.location?.coordinate.longitude)!)
                
            } else {
                //KSToastView.ks_showToast("Please Enter Valid ZipCode!", duration: ToastDuration)
            }
            } as CLGeocodeCompletionHandler)
    }
    
    //MARK: Show Alert
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Chicago Callsheet", message:msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
