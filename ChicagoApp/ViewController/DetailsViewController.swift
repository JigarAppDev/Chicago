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
import CoreData

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
    var likedObjArr = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getAllSavedData()
        
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
            self.saveObjInUD()
        } else {
            self.btnLike.setImage(UIImage.init(named: "disable_like_icon"), for: .normal)
            sender.isSelected = false
            self.removeSavedObjInID()
        }
    }
    
    func getAllSavedData() {
        //Core Data
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LikesTable")
        request.predicate = NSPredicate(format: "id = %@", self.selectedObj["id"].stringValue)
        request.returnsObjectsAsFaults = false
        do {
            if let result = try? context.fetch(request) {
                if result.count > 0 {
                    self.btnLike.setImage(UIImage.init(named: "like_icon"), for: .normal)
                    self.btnLike.isSelected = true
                }
            }
            
        } catch {
            print("Failed")
        }
    }
    
    func saveObjInUD() {
        //Core Data
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "LikesTable", in: context)
        let newData = NSManagedObject(entity: entity!, insertInto: context)
        newData.setValue(self.selectedObj["id"].intValue, forKey: "id")
        newData.setValue(self.selectedObj["Company_name"].stringValue, forKey: "company_name")
        newData.setValue(self.selectedObj["three_sentence_summary"].stringValue, forKey: "three_sentence_summary")
        newData.setValue(self.selectedObj["Client_Subbmission_link"].stringValue, forKey: "client_subbmission_link")
        newData.setValue(self.selectedObj["Phone"].stringValue, forKey: "phone")
        newData.setValue(self.selectedObj["Address"].stringValue, forKey: "address")
        newData.setValue(self.selectedObj["Website"].stringValue, forKey: "website")
        
        do {
           try context.save()
          } catch {
           print("Failed saving")
        }
    }
    
    func removeSavedObjInID() {
        
        //Core Data
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LikesTable")
        request.predicate = NSPredicate(format: "id = %@", self.selectedObj["id"].stringValue)
        request.returnsObjectsAsFaults = false
        do {
            if let result = try? context.fetch(request) {
                for object in result {
                    context.delete(object as! NSManagedObject)
                }
            }
            
        } catch {
            print("Failed")
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
    
    func archiveWidgetDataArray(likeDataArray : [JSON]) -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: likeDataArray, requiringSecureCoding: false)

            return data
        } catch {
            fatalError("Can't encode data: \(error)")
        }
    }

    func loadWidgetDataArray() -> [JSON]? {
        guard
            let unarchivedObject = UserDefaults.standard.data(forKey: "likeData")
        else {
            return nil
        }
        do {
            guard let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as? [JSON] else {
                fatalError("loadWidgetDataArray - Can't get Array")
            }
            return array
        } catch {
            fatalError("loadWidgetDataArray - Can't encode data: \(error)")
        }
    }
}

class LikeObject: NSObject {

    var likeId: Int
    var Company_name: String
    var three_sentence_summary: String
    var Client_Subbmission_link: String
    var Phone: String
    var Address: String
    var Website: String
    
    init(lid: Int, cname: String, summary: String, link: String, phone: String, addr: String, website: String){
        self.likeId = lid
        self.Company_name = cname
        self.three_sentence_summary = summary
        self.Client_Subbmission_link = link
        self.Phone = phone
        self.Address = addr
        self.Website = website
    }

    required init(coder aDecoder: NSCoder) {
        self.likeId = aDecoder.decodeInteger(forKey: "id")
        self.Company_name = aDecoder.decodeObject(forKey:"Company_name") as! String
        self.three_sentence_summary = aDecoder.decodeObject(forKey: "three_sentence_summary") as! String
        self.Client_Subbmission_link = aDecoder.decodeObject(forKey: "Client_Subbmission_link") as! String
        self.Phone = aDecoder.decodeObject(forKey: "Phone") as! String
        self.Address = aDecoder.decodeObject(forKey: "Address") as! String
        self.Website = aDecoder.decodeObject(forKey: "Website") as! String
    }

    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encode(likeId, forKey: "id")
        aCoder.encode(Company_name, forKey: "Company_name")
        aCoder.encode(three_sentence_summary, forKey: "three_sentence_summary")
        aCoder.encode(Client_Subbmission_link, forKey: "Client_Subbmission_link")
        aCoder.encode(Phone, forKey: "Phone")
        aCoder.encode(Address, forKey: "Address")
        aCoder.encode(Website, forKey: "Website")
    }

}

