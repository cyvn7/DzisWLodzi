//
//  JSONClass.swift
//  DzisWLodzi
//
//  Created by Maciej Przybylski on 03/01/2020.
//  Copyright © 2020 Maciej Przybylski. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON



class JSONClass {
    class func getJSON(linkArray: [String], completion : @escaping ([JSON],UIAlertController)->(Void)){
        var resultJSONS = [JSON]()
        var alert = UIAlertController()
        var count = 1
        for link in linkArray {
            print(link)
            AF.request("https://www.dziswlodzi.pl\(link)").validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.data {
                        do  {
                            resultJSONS.append(try JSON(data: json))
                        }
                        catch {
                            
                            alert = UIAlertController(title: "Błąd", message: "Aplikacja nie mogła pobrać danych", preferredStyle: .alert)

                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            break
                        }

                    }
                case .failure:
                    
                    alert = UIAlertController(title: "Błąd", message: "Brak połączenia internetowego", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    break
                }
                
                if count == linkArray.count {
                    completion(resultJSONS, alert)
                }
                else{
                    count+=1
                }
            }
        }
        
    }
    
    
}
