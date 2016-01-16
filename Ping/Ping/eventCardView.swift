//
//  eventCardView.swift
//  Ping
//
//  Created by Shreyash Agrawal on 1/11/16.
//  Copyright © 2016 shreyanshu. All rights reserved.
//

import UIKit

class eventCardView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    let imageView = UIImageView()
    let eventNameLabel = UILabel()
    let eventStartDateLabel = UILabel()
    let eventEndDateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 10.0
        
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        eventNameLabel.textAlignment = NSTextAlignment.Center
        eventNameLabel.text = "Event Name"
        
        eventStartDateLabel.textAlignment = NSTextAlignment.Center
        eventStartDateLabel.text = "Event Date"
        
        eventEndDateLabel.textAlignment = NSTextAlignment.Center
        eventEndDateLabel.text = "Event Date"
        
        self.addSubview(imageView)
        self.addSubview(eventNameLabel)
        self.addSubview(eventStartDateLabel)
        self.addSubview(eventEndDateLabel)
    }
    
    override func layoutSubviews() {
        let imageHeight = self.frame.height - 90;
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: imageHeight)
        eventNameLabel.frame = CGRect(x: 0, y: imageHeight, width: frame.width, height: 30)
        eventStartDateLabel.frame = CGRect(x: 0, y: imageHeight+30, width: frame.width, height: 30)
        eventEndDateLabel.frame = CGRect(x: 0, y: imageHeight+60, width: frame.width, height: 30)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setImage(image: UIImage){
        self.imageView.image = image
    }
    
    func setEventName(text: String){
        self.eventNameLabel.text = text
    }
    
    func setEventStartDate(text: String){
        self.eventStartDateLabel.text = text
    }
    
    func setEventEndDate(text: String){
        self.eventEndDateLabel.text = text
    }

    func getEventName()->String {
        return self.eventNameLabel.text!
    }
    
    func getEventStartDate()->NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, MMM dd yyyy hh:mm a"
        let eventDate = dateFormatter.dateFromString(self.eventStartDateLabel.text!)
        return eventDate!
    }
    
    func getEventEndDate()->NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, MMM dd yyyy hh:mm a"
        
        let eventDate = dateFormatter.dateFromString(self.eventEndDateLabel.text!)
        return eventDate!
    }

}
