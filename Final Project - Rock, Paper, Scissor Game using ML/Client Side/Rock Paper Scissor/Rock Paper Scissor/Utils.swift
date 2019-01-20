//
//  Utils.swift
//
//
//  Created by Dhaval Gogri on 12/03/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import Foundation
import UIKit

public class Utils {
    
    
    static func getYPosition(y : Double, error: CGFloat...) -> CGFloat{
        /*
        Note:- 
         error[0] = 5
         error[1] = 6
         error[2] = 6P
        */
        let screenSize: CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        let basicPosition = ((CGFloat(y) * screenHeight) / 568)
        return basicPosition
//        switch(screenHeight){
//            case 568.0:
//                return basicPosition + ((error[0] * screenHeight) / 568)
//            case 667.0:
//                return basicPosition + ((error[1] * screenHeight) / 568)
//            case 736.0:
//                return basicPosition + ((error[2] * screenHeight) / 568)
//            case 1218.0:
//                return basicPosition + ((error[3] * screenHeight) / 568)
//            default:
//                return basicPosition + ((error[0] * screenHeight) / 568)
//        }
    }
    
    
    static func getXPosition(x : Double, error: CGFloat...) -> CGFloat{
        /*
         Note:-
         error[0] = 5
         error[1] = 6
         error[2] = 6P
         */
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let basicPosition = ((CGFloat(x) * screenWidth) / 320)
        return basicPosition
//        switch(screenWidth){
//        case 320.0:
//            return basicPosition + ((error[0] * screenWidth) / 320)
//        case 375.0:
//            return basicPosition + ((error[1] * screenWidth) / 320)
//        case 414.0:
//            return basicPosition + ((error[2] * screenWidth) / 320)
//        default:
//            return basicPosition + ((error[0] * screenWidth) / 320)
//        }
    }
    
    
    //MARK: JSON Conversion Functions
    static func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    //Converting the data we get from the server to an NSDictionary
    static func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                                 options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            print("json error: \(error.localizedDescription)")
            return NSDictionary() // just return empty
        }
    }
    
    
}
