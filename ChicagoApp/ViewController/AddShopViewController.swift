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

class AddShopViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NVActivityIndicatorViewable {

    @IBOutlet var shopImage: UIImageView!
    @IBOutlet var btnAddImage: UIButton!
    @IBOutlet var txtShopname: UITextField!
    @IBOutlet var txvAbout: UITextView!
    @IBOutlet var txtLocation: UITextField!
    @IBOutlet var txtMobile: UITextField!
    @IBOutlet var txtEmail: UITextField!
    
    var ArrUploadFile = NSMutableArray()
    private var toast: JYToast!
    var lati = 0.0
    var longi = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initUi()
        self.txtShopname.becomeFirstResponder()
    }
    
    private func initUi() {
        toast = JYToast.init()
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func isValidated() -> Bool {
        var isFlag = true
        if self.ArrUploadFile.count == 0 {
            self.toast.isShow("Please Add Shop Logo!")
            isFlag = false
        } else if self.txtShopname.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            self.toast.isShow("Please Enter Shopname!")
            isFlag = false
        } else if self.txvAbout.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            self.toast.isShow("Please Enter About Info!")
            isFlag = false
        } else if self.txtLocation.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            self.toast.isShow("Please Enter Location!")
            isFlag = false
        } else if self.txtMobile.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            self.toast.isShow("Please Enter Mobile Number!")
            isFlag = false
        } else if self.txtEmail.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
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
        let Url = String(format: APIConstants.ADDSHOP)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        
        //let paramString = "shop_name=\(self.txtShopname.text!)&about=\(self.txvAbout.text!)&location=\(self.txtLocation.text!)&mobile_number=\(self.txtMobile.text!)&email=\(self.txtEmail.text!)&latitude=\(self.lati)&longitude=\(self.longi)"
        //request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let paramString = [ "shop_name":self.txtShopname.text!,"about":self.txvAbout.text!,"location":self.txtLocation.text!,"mobile_number":self.txtMobile.text!,"email":self.txtEmail.text!,"latitude":"\(self.lati)","longitude":"\(self.longi)"] as [String : Any]
        
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let imageData = self.ArrUploadFile[0]
        request.httpBody = createBodyWithParameters(parameters: paramString as? [String : String], filePathKey: "shop_image", imageDataKey: imageData as! NSData, boundary: boundary) as Data

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
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    if dataObj1["status_code"].intValue == 1 {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
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
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
