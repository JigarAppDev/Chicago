//
//  DetailsViewController.swift
//  ChicagoApp
//
//  Created by Jigar on 11/11/19.
//  Copyright © 2019 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import MessageUI
import CoreLocation
import MapKit

class DetailsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var imgCategory: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblAbout: UILabel!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblMobile: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var lblWebsite: UILabel!
    @IBOutlet var emailView: UIView!
    @IBOutlet var emailViewHeight: NSLayoutConstraint!
    @IBOutlet var imgMap: UIImageView!
    var selectedObj: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.lblTitle.text = self.selectedObj["Company_name"].stringValue
        self.lblName.text = self.selectedObj["Company_name"].stringValue
        self.lblAbout.text = self.selectedObj["three_sentence_summary"].stringValue
        self.lblEmail.text = self.selectedObj["Client_Subbmission_link"].stringValue
        self.lblMobile.text = self.selectedObj["Phone"].stringValue
        self.lblLocation.text = self.selectedObj["Address"].stringValue
        self.lblWebsite.text = self.selectedObj["Website"].stringValue
        self.imgCategory!.sd_setImage(with: URL(string: self.selectedObj["profile_pic"].stringValue), placeholderImage: UIImage(named: "icon.png"))
        
        self.emailView.isHidden = false
        self.emailViewHeight.constant = 76
        if self.selectedObj["Client_Subbmission_link"].stringValue == ""{
            self.emailView.isHidden = true
            self.emailViewHeight.constant = 0
        }
            
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Like-DisLike Click
    @IBAction func btnLikeClick(sender: UIButton) {
        if sender.isSelected == false {
            self.btnLike.setImage(UIImage.init(named: "like_icon"), for: .normal)
            sender.isSelected = true
        } else {
            self.btnLike.setImage(UIImage.init(named: "disable_like_icon"), for: .normal)
            sender.isSelected = false
        }
    }
    
    //MARK: Make Call
    @IBAction func btnMakeCall(sender: UIButton) {
        var phone = self.selectedObj["Phone"].stringValue
        if phone == "" {
            return
        }
        phone = phone.replacingOccurrences(of: "-", with: "")
        phone = phone.replacingOccurrences(of: "(", with: "")
        phone = phone.replacingOccurrences(of: ")", with: "")
        phone = phone.replacingOccurrences(of: " ", with: "")
        
        if let phoneCallURL = URL(string: "telprompt://\(phone)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    application.openURL(phoneCallURL as URL)
                    
                }
            }
        }
    }

    //MARK: Send Mail
    @IBAction func sendEmail(sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([self.selectedObj["Client_Subbmission_link"].stringValue])
            mail.setSubject("Chicago Callsheet Referral")
            //mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            present(mail, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    //MARK: Open Website
    @IBAction func openWebsite(sender: UIButton) {
        if let webURL = URL(string: self.selectedObj["Website"].stringValue), UIApplication.shared.canOpenURL(webURL)
        {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
    
    //MARK: Open in map
    @IBAction func btnOpenInMap(sender: UIButton) {
        let address = self.selectedObj["Address"].stringValue
        if address == "" {
            return
        }
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                // handle no location found
                return
            }
            
            let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.02))
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
            mapItem.name = self.selectedObj["Company_name"].stringValue
            mapItem.openInMaps(launchOptions: options)
        }
    }
}
