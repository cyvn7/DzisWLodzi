//
//  ViewController.swift
//  DzisWLodzi
//
//  Created by Maciej Przybylski on 01/11/2019.
//  Copyright © 2019 Maciej Przybylski. All rights reserved.
//


//F9AF20 - łódzka pomarańcz!!

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class MapViewClass: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //MARK: outlety i wartości
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var lodzView: MKMapView!
    @IBOutlet weak var detailBkg: UIImageView!
    @IBOutlet weak var shadow: UIImageView!
    @IBOutlet weak var detailTitle: UILabel!
    
    let defaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    let dwlURL = "https://www.dziswlodzi.pl"
    
    var curID = Int()
    var attractionsJSON = JSON()
    var categoriesJSON = JSON()
    var selectedCategoriesIDs = [Int]()
    var jsonDict = [Int: annonationValue]()
    var ind = 0
    
    typealias annonationValue = (lat: Double, long: Double , imageLink: String, title: String, categoryIds : [Int], website : String)

    //MARK: Funkcje mapy
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) ->
    MKAnnotationView?
    {
        if (annotation.isKind(of: MKUserLocation.self)){
            return nil
        }
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom pin")
        if !(annotation is MKUserLocation) {
            let a = annotation as! LodzPin
            let identifier = a.id
            var primImage = String()
            var secImage = String()
            //print(jsonDict[identifier!]!.categoryIds)
            //let catID = jsonDict[identifier!]!.categoryIds[0]
            for catID in jsonDict[identifier!]!.categoryIds {
                //print(categoriesJSON["\(catID)"]["parent_id"].intValue)
                if categoriesJSON["\(catID)"]["parent_id"].intValue == 5 {
                    secImage = "Museum"
                } else if catID == 199 {
                    primImage = "Shop"
                } else if catID == 249 || catID == 26 || catID == 24{
                    primImage = "Aqua"
                } else if catID == 92 || catID == 7 || catID == 63 || catID == 157 || catID == 241 || catID == 313 || catID == 314 || catID == 325 {
                    primImage =  "Sport"
                } else if catID == 28 || catID == 25 || catID == 31 {
                    primImage =  "Eco"
                } else if categoriesJSON["\(catID)"]["parent_id"].intValue == 7 {
                    secImage =  "Amu"
                }
            }
            
            if primImage != String() {
                annotationView.image = UIImage(named: "\(primImage)Pin")
            } else if secImage != String() {
                annotationView.image = UIImage(named: "\(secImage)Pin")
            } else {
                annotationView.image = UIImage(named: "EmptyPin")
            }
        }
        else {
           // annotationView.image = UIImage(named: "locationImage")
        }
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            //mówimy że nie działa lokalizacja
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let a = view.annotation as? LodzPin else {
            return
        }
        let identifier = a.id
        curID = identifier!
        print(jsonDict[identifier!]!.categoryIds)
        detailTitle.text! = jsonDict[identifier!]!.title
        AF.download("\(dwlURL)\(jsonDict[identifier!]!.imageLink)").responseData {
          response in
              if let data = response.value {
                   let image = UIImage(data: data)
                //self.detailBkg.image = image
                UIView.transition(with: self.detailBkg,
                duration: 0.75,
                options: .transitionCrossDissolve,
                animations: { self.detailBkg.image = image },
                completion: nil)
               }
        }
        detailView.isHidden = false
        centerDotView(lat: jsonDict[identifier!]!.lat, long: jsonDict[identifier!]!.long)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        detailView.isHidden = true
        curID = Int()
    }

    
    func centerDotView(lat: Double, long: Double) {
        let loc = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        if lat == 0.0 && long == 0.0 {
            if let location = locationManager.location?.coordinate{
                let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
                lodzView.setRegion(region, animated: true)
            }
        }
        else {
            let region = MKCoordinateRegion.init(center: loc, latitudinalMeters: 1000, longitudinalMeters: 1000)
            lodzView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationAuthorization() {
        print("im blue badibibiba")
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            lodzView.showsUserLocation = true
            lodzView.showsCompass = true
            locationManager.startUpdatingLocation()
            centerDotView(lat: 0.0, long: 0.0)
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        }
    }
    
    //MARK: Funkcje pobierania i wstawiania
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
       URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
        func getMapData() {
            print("hello")
            var internetConnection = true
            

            AF.request("\(dwlURL)/company-directory/company/json-categories").validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.data {
                        do  {
                            self.categoriesJSON = try JSON(data: json)
                            print("hi")
                            
                        }
                        catch{
                            print("JSON Error")
                        }

                    }
                case .failure:
                    //MARK: Wyświetl problem z internetem
                    print("ebedebe")
                    internetConnection = false
                }
                
                
            }
            AF.request("\(dwlURL)/company-directory/company/json").validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.data {
                        do  {
                            //self.attractionsJSON = try JSON(data: json)
                            print("hi")
                            self.displayAnnonations()
                        }
                        catch{
                            print("JSON Error")
                        }

                    }
                case .failure:
                    //MARK: Wyświetl problem z internetem
                    print("ebedebe")
                    internetConnection = false
                }
                
                
            }
            if internetConnection == false {
                //Wyświetl problem z internetem
                print("bez internetu")
            }
            else {
                displayAnnonations()
            }
        }
        
        
        
        func displayAnnonations() {
            print("displayanno")
            lodzView.removeAnnotations(lodzView.annotations)
            let selectedCategories = (defaults.array(forKey: "selectedCategories") ?? [Int]()) as! [Int]
            for (index,subJson):(String, JSON) in attractionsJSON {
                    let indexcx = Int(index)!
                    //annotation.id = Int(index)!
                jsonDict[indexcx] = annonationValue(lat: subJson["geo_latitude"].doubleValue, long: subJson["geo_longitude"].doubleValue, imageLink: subJson["img"].stringValue, title: subJson["title"].stringValue, categoryIds: subJson["additional_categories"].arrayValue.map { $0.intValue}, website: subJson["url"].stringValue)
    //            jsonDict[indexcx] = annonationValue(lat: attractionsJSON[indexcx]["geo_latitude"].doubleValue, long: attractionsJSON[indexcx]["geo_longitude"].doubleValue, imageLink: attractionsJSON[indexcx]["img"].stringValue, title: attractionsJSON[indexcx]["title"].stringValue, categoryIds: attractionsJSON[indexcx]["additional_categories"].arrayValue.map { $0.stringValue})
                let annotation = LodzPin(id: indexcx, lat: jsonDict[indexcx]!.lat, long: jsonDict[indexcx]!.long)
                for catid in jsonDict[indexcx]!.categoryIds {
                    if (selectedCategories != [Int]() && selectedCategories.contains(catid)) || selectedCategories == [Int]() {
                        lodzView.addAnnotation(annotation)
                    }
                }
               // print(attractionsJSON[indexcx]["geo_latitude"].doubleValue)
            }
        }
    

    //MARK: Akcje przycisków
    
    @IBAction func centerBtnAction(_ sender: Any) {
        centerDotView(lat: 0.0, long: 0.0)
        detailView.isHidden = true
    }
    
    @IBAction func routeBtnAct(_ sender: Any) {
        let latitude: CLLocationDegrees = jsonDict[curID]!.lat
        let longitude: CLLocationDegrees = jsonDict[curID]!.long

        let regionDistance:CLLocationDistance = 100
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = jsonDict[curID]?.title
        mapItem.openInMaps(launchOptions: options)
        
    }
    
    
    @IBAction func websiteBtnAct(_ sender: Any) {
        if let url = URL(string: "http://www.dziswlodzi.pl/\(jsonDict[curID]!.website)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    

    //MARK: Reszta
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        lodzView.delegate = self
        // Do any additional setup after loading the view.
        //getMapData()
        checkLocationServices()
        detailView.isHidden = true
        detailView.layer.cornerRadius = 10
        detailBkg.layer.cornerRadius = 10
        shadow.layer.cornerRadius = 10
        JSONClass.getJSON(linkArray: ["/company-directory/company/json", "/company-directory/company/json-categories"]) { jsonFiles,alert  in
            if jsonFiles != [JSON]() {
                self.attractionsJSON = jsonFiles[1]
                self.categoriesJSON = jsonFiles[0]
                self.displayAnnonations()
            }
            else {
                self.present(alert, animated: true)
            }
        }
    }

    
    @objc func defaultsChanged() {
        displayAnnonations()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    
    
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        if segue.identifier == "goToCat" {
            
            let fvc = segue.destination as! UINavigationController
            let destinationFVC = fvc.topViewController as! MapCategoryView
            //destinationFVC.modalPresentationStyle = .popover
                for (index,subJson):(String, JSON) in categoriesJSON {
                    let p_id = subJson["parent_id"].intValue
                    let id = subJson["id"].intValue
                    if p_id == 5 {
                        destinationFVC.categoryMonuments[subJson["name"].stringValue] = id
                    }
                    else if p_id == 7 {
                        destinationFVC.categoryAttractions[subJson["name"].stringValue] = id
                    }
                
            }
            
        }
        
        //print(categoriesJSON)
    }
    
}


class LodzPin: NSObject, MKAnnotation {

    var id: Int?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(id: Int, lat: Double, long: Double) {
        self.id = id
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

    }
    
    

}

