//
//  LocationListViewController.swift
//  ChicagoApp
//
//  Created by Jigar on 11/11/19.
//  Copyright © 2019 Jigar. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit

class LocationCell: UITableViewCell {
    @IBOutlet var lblName: UILabel!
}

class LocationListViewController: UIViewController {

    @IBOutlet var tblLocation: UITableView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var mapView: UIView!
    @IBOutlet var segmentView: UISegmentedControl!
    @IBOutlet var mapKitView: MKMapView!

    var selectedObj: JSON!
    var categoryArray = [JSON]()
    var mapAnnoArray = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblTitle.text = self.selectedObj["category_name"].stringValue
        self.getAllCategory()
        self.mapView.isHidden = true
        self.tblLocation.isHidden = false
        self.mapKitView.delegate = self
    }
    
    // MARK: - Back Click
    @IBAction func btnBackClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: Category API Call
    private func getAllCategory() {
        
        let Url = String(format: APIConstants.GetCategoryDetails)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        let paramString = "category_id=\(self.selectedObj["category_id"])"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
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
                        self.categoryArray.removeAll()
                        self.categoryArray = dataObj1["info"].arrayValue
                    }
                    DispatchQueue.main.async {
                        self.tblLocation.reloadData()
                    }
                    self.mapAnnoArray.removeAll()
                    self.showMarkerOnMap()
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    //MARK: TV Click
    @IBAction func btnTVClick(sender: UIButton) {
        if let webURL = URL(string: "https://www.chicagocallsheet.com/"), UIApplication.shared.canOpenURL(webURL)
        {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
    
    //MARK: Get Liked Data
    @IBAction func btnLikeClick(sender: UIButton) {
        let likeVC = self.storyboard?.instantiateViewController(identifier: "LikedCategoryViewController") as! LikedCategoryViewController
        self.navigationController?.pushViewController(likeVC, animated: true)
    }
    
    //MARK: Segment Click Event
    @IBAction func segmentedControlValueChanged(segment:UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            //List
            self.mapView.isHidden = true
            self.tblLocation.isHidden = false
            self.tblLocation.reloadData()
        } else {
            //Map
            self.mapView.isHidden = false
            self.tblLocation.isHidden = true
            self.mapKitView.fitAllAnnotations()
        }
    }
    
    //MARK: Get Lat long to show marker on map
    func showMarkerOnMap() {
        for obj in self.categoryArray {
            let address = obj["Address"].stringValue
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
                let annotation = MKPointAnnotation()
                annotation.title = obj["Company_name"].stringValue
                annotation.coordinate = coordinate
                self.mapKitView.addAnnotation(annotation)
            }
        }
        self.mapKitView.fitAllAnnotations()
    }
}

extension LocationListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblLocation.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
        let obj = self.categoryArray[indexPath.row]
        cell.lblName.text = obj["Company_name"].stringValue
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = self.storyboard?.instantiateViewController(identifier: "DetailsViewController") as! DetailsViewController
        let obj = self.categoryArray[indexPath.row]
        detailsVC.selectedObj = obj
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
}

extension LocationListViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKMarkerAnnotationView()
        guard let annotation = annotation as? MKPointAnnotation else {return nil}
        let identifier = ""
        annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView.markerTintColor = .blue
        annotationView.glyphImage = UIImage(named: "map_pin_icon")
        annotationView.clusteringIdentifier = identifier
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if self.categoryArray.count > 0 {
            for obj in self.categoryArray {
                if obj["Company_name"].stringValue == view.annotation?.title {
                    let detailsVC = self.storyboard?.instantiateViewController(identifier: "DetailsViewController") as! DetailsViewController
                    detailsVC.selectedObj = obj
                    self.navigationController?.pushViewController(detailsVC, animated: true)
                    break
                }
            }
        }
    }
}

extension MKMapView {
    func fitAllAnnotations() {
        
        guard annotations.count > 0 else {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }

        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        region = regionThatFits(region)
        setRegion(region, animated: true)
    }
}
