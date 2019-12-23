//
//  AddShopViewController.swift
//  ChicagoApp
//
//  Created by Vivek on 23/12/19.
//  Copyright © 2019 Jigar. All rights reserved.
//

import UIKit

class AddShopViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var shopImage: UIImageView!
    @IBOutlet var btnAddImage: UIButton!
    @IBOutlet var txtShopname: UITextField!
    @IBOutlet var txvAbout: UITextView!
    @IBOutlet var txtLocation: UITextField!
    @IBOutlet var txtMobile: UITextField!
    @IBOutlet var txtEmail: UITextField!
    
    var ArrUploadFile = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Submit Click
    @IBAction func btnSubmitClick(sender: UIButton) {
        
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
}
