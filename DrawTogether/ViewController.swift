//
//  ViewController.swift
//  DrawTogether
//
//  Created by Benji Brown on 1/31/16.
//  Copyright © 2016 Studio B Flat LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var drawImage = UIImageView()
    var polylines: [Polyline] = []
    var currentPolyline: Polyline!
    var lastPoint: CGPoint!
    
    var liveQuery: CBLLiveQuery!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate

        // Do any additional setup after loading the view, typically from a nib.
        drawImage.frame = view.bounds
        view.addSubview(drawImage)
        liveQuery = appDelegate!.kDatabase!.createAllDocumentsQuery().asLiveQuery()
        liveQuery.addObserver(self, forKeyPath: "rows", options: NSKeyValueObservingOptions.New, context: nil)

        if let error = try? liveQuery.run() {
            print(error)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (object as! CBLLiveQuery) == liveQuery {
            polylines.removeAll(keepCapacity: false)
            
            for (index, row) in liveQuery.rows!.allObjects.enumerate() {
                polylines.append(Polyline(forDocument: (row as! CBLQueryRow).document!))
            }
            
            drawPolylines()
        }
    }
    
    
    func drawPolylines() {
        drawImage.image = nil
        UIGraphicsBeginImageContext(view.bounds.size)
        drawImage.image?.drawInRect(view.bounds)
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1)
        CGContextBeginPath(UIGraphicsGetCurrentContext())
        
        for polyline in polylines {
            if let firstPoint = polyline.points.first {
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), firstPoint["x"]!, firstPoint["y"]!)
            }
            
            for point in polyline.points {
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point["x"]!, point["y"]!)
            }
        }
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        drawImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: ACTIONS
    @IBAction func clearTap(sender: AnyObject) {
        for polyline in polylines {
            if let error = try? polyline.deleteDocument() {
                print(error)
            }
        }
        polylines = []
        drawImage.image = nil
    }
    
    //MARK: DRAWING METHODS
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        lastPoint = touches.first!.locationInView(view)
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate

        currentPolyline = Polyline(forNewDocumentInDatabase: appDelegate!.kDatabase!)
        currentPolyline.points.append(["x" : lastPoint.x, "y" : lastPoint.y])
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let point = touches.first!.locationInView(view)
        currentPolyline.points.append(["x" : point.x, "y" : point.y])
        
        UIGraphicsBeginImageContext(view.bounds.size)
        drawImage.image?.drawInRect(view.bounds)
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1)
        CGContextBeginPath(UIGraphicsGetCurrentContext())
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point.x, point.y)
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        drawImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        lastPoint = point
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let error = try? currentPolyline.save() {
            print(error)
        }

    }
    
}

