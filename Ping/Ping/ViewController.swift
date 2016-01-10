//
//  ViewController.swift
//  Ping
//
//  Created by Shreyash Agrawal on 10/3/15.
//  Copyright © 2015 shreyanshu. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    var currentEventId = ""
    
    @IBOutlet var eventCard: UIImageView!
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.performSegueWithIdentifier("logoutSegue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let testObject = PFObject(className: "TestObject")
//        testObject["foo"] = "bar"
//        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//            print("Object has been saved.")
//        }
        
//        let label = UILabel(frame: CGRectMake(self.view.bounds.width/2 - 100, self.view.bounds.height/2 - 50, 200, 100))
//        label.text = "DRAG Me"
//        label.textAlignment = NSTextAlignment.Center
//        self.view.addSubview(label)
        
        
        let gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
        eventCard.addGestureRecognizer(gesture)
        eventCard.userInteractionEnabled = true
        updateImage()
        
    }
    
    func updateImage() {
        //TODO: Need to add further constraints to make sure viewed events don't show
        let query = PFQuery(className: "Events")
        query.limit = 1
        query.whereKey("attending", notEqualTo: PFUser.currentUser()!)
        query.whereKey("notAttending", notEqualTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) events.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        self.currentEventId = object.objectId!
                        print(object.objectId)
                        let imageFile = object["Image"]
                        imageFile.getDataInBackgroundWithBlock{
                            (imageData: NSData?, error: NSError?) -> Void in
                            
                            if error != nil {
                                print(error)
                            } else{
                                if let data = imageData{
                                    self.eventCard.image = UIImage(data: data)
                                }
                            }
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    func wasDragged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(self.view)
        
        let eventCard = gesture.view!
        eventCard.center = CGPoint(x: self.view.bounds.width/2 + translation.x, y: self.view.bounds.height/2 + translation.y)
        
        let xFromCenter = eventCard.center.x - self.view.bounds.width/2
        
        var rotation = CGAffineTransformMakeRotation(xFromCenter/200)
        
        let scale = min(100/abs(xFromCenter),1)
        
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        eventCard.transform = stretch
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            var acceptedOrRejected = ""
            var attendingOrNot = ""
            
            if eventCard.center.x < 100 {
                acceptedOrRejected = "rejectedEvents"
                attendingOrNot = "notAttending"
            } else if eventCard.center.x > self.view.bounds.width - 100 {
                acceptedOrRejected = "acceptedEvents"
                attendingOrNot = "attending"
            }
            
            if acceptedOrRejected != "" {
                PFUser.currentUser()?.addUniqueObject(currentEventId, forKey: acceptedOrRejected)
                PFUser.currentUser()?.saveInBackground() //TODO: Fix this asynchronous code
                updateEventAttendance(currentEventId, isAttending: attendingOrNot)
            }
            
            rotation = CGAffineTransformMakeRotation(0)
            
            stretch = CGAffineTransformScale(rotation, 1, 1)
            
            eventCard.transform = stretch
            
            eventCard.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
            
//            updateImage() //Image Updates after finger is released
        }
    }
    
    func updateEventAttendance(eventId: String, isAttending: String) {
        let query = PFQuery(className:"Events")
        query.getObjectInBackgroundWithId(eventId) {
            (event: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let event = event {
                event.addUniqueObject(PFUser.currentUser()!, forKey: isAttending)
                event.saveInBackgroundWithBlock{
                    (success: Bool, error: NSError?) -> Void in
                    if (error == nil) {
                        self.updateImage()
                    } else {
                        print(error)
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

