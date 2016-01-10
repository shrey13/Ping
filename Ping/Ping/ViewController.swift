//
//  ViewController.swift
//  Ping
//
//  Created by Shreyash Agrawal on 10/3/15.
//  Copyright © 2015 shreyanshu. All rights reserved.
//

import UIKit
import Parse
import EventKit

class ViewController: UIViewController {

//    var currentEventId = ""
    var listOfEvents = [String]()
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.performSegueWithIdentifier("logoutSegue", sender: self)
        }
    }
    
    @IBAction func restParseButton(sender: AnyObject) {
        let query = PFQuery(className: "Events")
        query.findObjectsInBackgroundWithBlock{
            (events: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for event in events! {
                    event.removeObjectForKey("attending")
                    event.removeObjectForKey("notAttending")
                }
                PFObject.saveAllInBackground(events)
                
                let alert = UIAlertView(title: "Reset", message: "Successfully Reset data", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                self.listOfEvents.removeAll()
                self.loadImages()
            } else {
                print(error)
            }
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
        
        
        
        loadImages()
        
    }
    
    func loadImages() {
        
        
        let query = PFQuery(className: "Events")
        query.limit = 5
        query.whereKey("attending", notEqualTo: PFUser.currentUser()!)
        query.whereKey("notAttending", notEqualTo: PFUser.currentUser()!)
        query.whereKey("objectId", notContainedIn: listOfEvents)
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Number of Events \(self.listOfEvents.count)")
                print("Successfully retrieved \(objects!.count) events.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
//                        self.currentEventId = object.objectId!
                        let imageFile = object["Image"]
                        imageFile.getDataInBackgroundWithBlock{
                            (imageData: NSData?, error: NSError?) -> Void in
                            
                            if error != nil {
                                print(error)
                            } else{
                                if let data = imageData{
                                    let eventImage = UIImageView(frame: CGRect(x: 20, y: 100, width: self.view.bounds.width-40, height: 350))
                                    eventImage.image = UIImage(data: data)
                                    eventImage.backgroundColor = UIColor.whiteColor()
                                    eventImage.layer.borderColor = UIColor.blackColor().CGColor
                                    eventImage.layer.borderWidth = 1.0
                                    eventImage.layer.cornerRadius = 10.0
                                    eventImage.contentMode = UIViewContentMode.ScaleAspectFit
                                    self.listOfEvents.append(object.objectId!)
                                    self.view.insertSubview(eventImage, atIndex: 2)
                                    let gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
                                    eventImage.addGestureRecognizer(gesture)
                                    eventImage.userInteractionEnabled = true
//                                    self.eventCard.image = UIImage(data: data)
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
        eventCard.center = CGPoint(x: self.view.bounds.width/2 + translation.x, y: 275 + translation.y)
        
        let xFromCenter = eventCard.center.x - self.view.bounds.width/2
        
        var rotation = CGAffineTransformMakeRotation(xFromCenter/400)
        
        let scale = min((self.view.bounds.width-abs(xFromCenter)/2)/self.view.bounds.width,1)
        
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        eventCard.transform = stretch
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            var acceptedOrRejected = ""
            var attendingOrNot = ""
            
            if eventCard.center.x < 75 {
                acceptedOrRejected = "rejectedEvents"
                attendingOrNot = "notAttending"
            } else if eventCard.center.x > self.view.bounds.width - 75 {
                acceptedOrRejected = "acceptedEvents"
                attendingOrNot = "attending"
            }
            
            rotation = CGAffineTransformMakeRotation(0)
            
            if acceptedOrRejected != "" {
                print(listOfEvents)
                PFUser.currentUser()?.addUniqueObject(listOfEvents[0], forKey: acceptedOrRejected)
                PFUser.currentUser()?.saveInBackground() //TODO: Fix this asynchronous code
                updateEventAttendance(listOfEvents[0], isAttending: attendingOrNot)
                listOfEvents.removeFirst()
                UIView.animateWithDuration(0.7, animations: {
                    if (acceptedOrRejected == "acceptedEvents") {
                        self.addEventToCalendar()
                        eventCard.center = CGPoint(x: self.view.bounds.width*2, y: eventCard.center.y)
                    } else {
                        eventCard.center = CGPoint(x: -self.view.bounds.width, y: eventCard.center.y)
                    }
                    }, completion: {
                        (value: Bool) in
                        eventCard.removeFromSuperview()
                })
            } else {
                stretch = CGAffineTransformScale(rotation, 1, 1)
                eventCard.transform = stretch
                eventCard.center = CGPoint(x: self.view.bounds.width/2, y: 275)
            }
            
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
                        if (self.listOfEvents.count <= 3) {
                            self.loadImages()
                        }
                    } else {
                        print(error)
                    }
                }
            }
        }
    }
    
    func addEventToCalendar() {
        let eventStore : EKEventStore = EKEventStore()
        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
        eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
            granted, error in
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error  \(error)")
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = "Test Title"
                event.startDate = NSDate()
                event.endDate = NSDate()
                event.notes = "This is a note"
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.saveEvent(event, span: EKSpan.ThisEvent, commit: true)
                } catch {
                    print(error)
                }
                print("Saved Event")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

