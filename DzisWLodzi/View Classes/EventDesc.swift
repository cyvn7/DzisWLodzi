import UIKit
import Alamofire
import SwiftyJSON
import MapKit

class EventDesc: UIViewController {


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    var titleStr = String()
    var descStr = String()
    var website = String()
    var date = String()
    var image = UIImage(data: Data())
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text! = titleStr
        dateLabel.text! = date
        imageView.image = image
        descLabel.text = descStr.html2String
    }

    
    @IBAction func websiteBtnAction(_ sender: Any) {
        let url: NSURL = URL(string: website)! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    
    
    
}

