//
//  CreateEventViewController.swift
//  Ping
//
//  Created by Shreyash Agrawal on 1/5/16.
//  Copyright © 2016 shreyanshu. All rights reserved.
//

import UIKit
import Parse

class CreateEventViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet var eventNameTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var eventStartTime: UIDatePicker!
    @IBOutlet var eventEndTime: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.eventNameTextField.delegate = self;
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func getEventDatePickerDate(datePicker: UIDatePicker) -> String{
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateString = dateFormatter.stringFromDate(datePicker.date)
        return dateString;
    }
    
    @IBAction func submitEvent(sender: AnyObject){
        
        activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let eventObject = PFObject(className: "Events")
        eventObject["Name"] = eventNameTextField.text;
        eventObject["startTime"] = eventStartTime.date // getEventDatePickerDate(eventStartTime);
        eventObject["endTime"] = eventEndTime.date // getEventDatePickerDate(eventEndTime);
        let imageData = UIImageJPEGRepresentation(imageView.image!, 1.0)
        let imageFile = PFFile(name: "image.png", data:imageData!)
        eventObject["Image"] = imageFile
        eventObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if error == nil {
                self.displayAlert("Event Created!", message: "Your event was successfully created")
                
                self.imageView.image = UIImage(named: "event-icon")
                self.eventNameTextField.text = ""
            } else {
                
                self.displayAlert("Failed!", message: "Please try again later")

            }
        }
        
        
        
    }
    
    @IBAction func uploadImageButton(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let image = UIImagePickerController()
        image.delegate = self
        image.allowsEditing = false
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            image.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(image, animated: true, completion:nil)
        })
        let imageGalleryAction = UIAlertAction(title: "Choose Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(image, animated: true, completion:nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(imageGalleryAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        print("Image Selected")
        self.dismissViewControllerAnimated(true, completion: nil)
        imageView.image = image;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
