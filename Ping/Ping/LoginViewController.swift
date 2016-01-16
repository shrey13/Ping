//
//  LoginViewController.swift
//  Ping
//
//  Created by Shreyash Agrawal on 1/9/16.
//  Copyright © 2016 shreyanshu. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import FBSDKCoreKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        let permissions = ["public_profile"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?)-> Void in
            
            if let error = error {
                print(error)
            } else{
                if let user = user {
                    print(user)
                    self.performSegueWithIdentifier("loginSegue", sender: self);
                    
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if let _ = PFUser.currentUser()?.username {
            performSegueWithIdentifier("loginSegue", sender: self)
        }
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
