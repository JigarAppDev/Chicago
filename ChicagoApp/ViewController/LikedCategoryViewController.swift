//
//  LikedCategoryViewController.swift
//  ChicagoApp
//
//  Created by Jigar on 23/11/19.
//  Copyright © 2019 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

class LikeCatCell: UITableViewCell {
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblAbout: UILabel!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblMobile: UILabel!
    @IBOutlet var lblEmail: UILabel!
}

class LikedCategoryViewController: UIViewController {

    @IBOutlet var tblLikedCat: UITableView!
    var likedObjArr = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblLikedCat.rowHeight = UITableView.automaticDimension
        self.tblLikedCat.estimatedRowHeight = 325
        
        self.getAllSavedData()
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getAllSavedData() {
        //CoreData
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LikesTable")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            self.likedObjArr.removeAll()
            for data in result as! [NSManagedObject] {
                let dic = NSMutableDictionary()
                dic.setValue(data.value(forKey: "address"), forKey: "address")
                dic.setValue(data.value(forKey: "client_subbmission_link"), forKey: "client_subbmission_link")
                dic.setValue(data.value(forKey: "company_name"), forKey: "company_name")
                dic.setValue(data.value(forKey: "id"), forKey: "id")
                dic.setValue(data.value(forKey: "phone"), forKey: "phone")
                dic.setValue(data.value(forKey: "three_sentence_summary"), forKey: "three_sentence_summary")
                dic.setValue(data.value(forKey: "website"), forKey: "website")
                self.likedObjArr.append(JSON.init(dic))
          }
            print(self.likedObjArr)
            self.tblLikedCat.reloadData()
        } catch {
            print("Failed")
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

extension LikedCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.likedObjArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblLikedCat.dequeueReusableCell(withIdentifier: "LikeCatCell") as! LikeCatCell
        let selectedObj = self.likedObjArr[indexPath.row]
        cell.lblName.text = selectedObj["company_name"].stringValue
        cell.lblAbout.text = selectedObj["three_sentence_summary"].stringValue
        cell.lblEmail.text = selectedObj["client_subbmission_link"].stringValue
        cell.lblMobile.text = selectedObj["phone"].stringValue
        cell.lblLocation.text = selectedObj["address"].stringValue
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

