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
    let eventCardYOrigin = CGFloat(100)
    let eventCardHeight = CGFloat(400)
    let currentEventCard = eventCardView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.       
        loadEventCards()
        
    }
    
    func loadEventCards() {
        
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
                        let eventCard = eventCardView(frame: CGRect(x: 20, y: 100, width: self.view.bounds.width-40, height: self.eventCardHeight))
                        
                        eventCard.setEventName(object["Name"] as! String)
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "EEE, MMM dd yyyy hh:mm a"
                        
                        let startDateTime = object["startTime"] as! NSDate
                        let endDateTime = object["endTime"] as! NSDate
                        eventCard.setEventStartDate(dateFormatter.stringFromDate(startDateTime))
                        eventCard.setEventEndDate(dateFormatter.stringFromDate(endDateTime))
                        
                        let imageFile = object["Image"]
                        imageFile.getDataInBackgroundWithBlock{
                            (imageData: NSData?, error: NSError?) -> Void in
                            
                            if error != nil {
                                print(error)
                            } else{
                                if let data = imageData{
                                    eventCard.setImage(UIImage(data: data)!)
                                    self.listOfEvents.append(object.objectId!)
                                    self.view.insertSubview(eventCard, atIndex: 2)
                                    let gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
                                    eventCard.addGestureRecognizer(gesture)
                                    eventCard.userInteractionEnabled = true
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
        let imageYCenter = eventCardYOrigin + eventCardHeight/2
        let translation = gesture.translationInView(self.view)
        
        let eventCard = gesture.view! as! eventCardView
        eventCard.center = CGPoint(x: self.view.bounds.width/2 + translation.x, y: imageYCenter + translation.y)
        
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
                        self.addEventToCalendar(eventCard)
                        eventCard.center = CGPoint(x: self.view.bounds.width*2, y: eventCard.center.y)
                    } else {
                        eventCard.center = CGPoint(x: -self.view.bounds.width, y: eventCard.center.y)
                    }
                    }, completion: {
                        (value: Bool) in
                        eventCard.removeFromSuperview()
                })
            } else {
                UIView.animateWithDuration(0.3, animations: {
                    stretch = CGAffineTransformScale(rotation, 1, 1)
                    eventCard.transform = stretch
                    eventCard.center = CGPoint(x: self.view.bounds.width/2, y: imageYCenter)
                })
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
                            self.loadEventCards()
                        }
                    } else {
                        print(error)
                    }
                }
            }
        }
    }
    
    func addEventToCalendar(eventCard: eventCardView) {
        let eventStore : EKEventStore = EKEventStore()
        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
        eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
            granted, error in
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error  \(error)")
                let event:EKEvent = EKEvent(eventStore: eventStore)
                print("Event Card \(eventCard)")
                event.title = eventCard.getEventName()
                print("Event Time in Calendar \(eventCard.getEventStartDate())")
                print("Event Time in Calendar \(eventCard.getEventEndDate())")
                event.startDate = eventCard.getEventStartDate()
                event.endDate = eventCard.getEventEndDate()
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
                self.loadEventCards()
            } else {
                print(error)
            }
        }
    }
}

