//
//  MapObjDesc.swift
//  DzisWLodzi
//
//  Created by Maciej Przybylski on 25/05/2020.
//  Copyright © 2020 Maciej Przybylski. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MapKit

class MapObjDesc: UIViewController {

    @IBOutlet weak var phoneBtnOutlet: UIButton!
    @IBOutlet weak var websiteBtnOutlet: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pricesLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    
    var objectDetail = (lat: Double(), long: Double(), imageLink: String(), title: String(), categoryIds : [Int](), website : String(), address : String(), tel : String(), prices : String(), hours : String(), desc : String())
    var image = UIImage(data: Data())
    var hoursConstraint = NSLayoutConstraint()
    var pricesConstraint = NSLayoutConstraint()
    var descConstraint = NSLayoutConstraint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text! = objectDetail.title
        addressLabel.text! = objectDetail.address
        imageView.image = image
        
        if objectDetail.website == String() {
            websiteBtnOutlet.isEnabled = false
        }
        if objectDetail.tel == String() {
            phoneBtnOutlet.isEnabled = false
        }
        
        
        
        
        if objectDetail.hours.contains("<p>") == true {
            hoursLabel.text = "🕑\n\(objectDetail.hours.html2String)"
        } else if objectDetail.hours == String() {
            hoursLabel.text = ""
        } else {
            hoursLabel.text = "🕑\n\(objectDetail.hours)"
        }
        
        if objectDetail.prices.contains("<p>") == true {
            pricesLabel.text = "💵\n\(objectDetail.prices.html2String)"
        } else if objectDetail.prices == String() {
            pricesLabel.text = ""
        } else {
            pricesLabel.text = "💵\n\(objectDetail.prices)"
        }
        
        if objectDetail.desc.contains("<p>") == true {
            descLabel.text = "\(objectDetail.desc.html2String)"
        } else if objectDetail.prices == String() {
            descLabel.text = ""
        } else {
            descLabel.text = "\(objectDetail.desc)"
        }
    }
    
    @IBAction func phoneBtnAction(_ sender: Any) {
        print("tel://\(objectDetail.tel.replacingOccurrences(of: " ", with: "-"))")
        if let url = URL(string: "tel://\(objectDetail.tel.replacingOccurrences(of: " ", with: "-"))") {
            UIApplication.shared.canOpenURL(url)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func websiteBtnAction(_ sender: Any) {
        let url: NSURL = URL(string: objectDetail.website)! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    @IBAction func routeBtnAction(_ sender: UIButton) {
        let latitude: CLLocationDegrees = objectDetail.lat
        let longitude: CLLocationDegrees = objectDetail.long

        let regionDistance:CLLocationDistance = 100
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = objectDetail.title
        mapItem.openInMaps(launchOptions: options)
    }
    
    
    
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String { html2AttributedString?.string ?? "" }
}

extension StringProtocol {
    var html2AttributedString: NSAttributedString? {
        Data(utf8).html2AttributedString
    }
    var html2String: String {
        html2AttributedString?.string ?? ""
    }
}
