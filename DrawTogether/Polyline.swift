//
//  Polyline.swift
//  DrawTogether
//
//  Created by Benji Brown on 1/31/16.
//  Copyright © 2016 Studio B Flat LLC. All rights reserved.
//

import UIKit

class Polyline: CBLModel {
    
    @NSManaged var points: [[String : CGFloat]]
    
    class func polylineInDatabase(database: CBLDatabase, withPoints points: [[String:CGFloat]]) -> Polyline {
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        let polyline = Polyline(forNewDocumentInDatabase: delegate!.kDatabase!)
        polyline.points = points
        
        return polyline
    }
    
}
