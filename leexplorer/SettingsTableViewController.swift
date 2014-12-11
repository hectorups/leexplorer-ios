//
//  SettingsTableViewController.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet var versionLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationItem.leftBarButtonItem?.tintColor = ColorPallete.White.get()
        navigationItem.leftBarButtonItem?.title = NSLocalizedString("SVC_CANCEL", comment: "")
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = "handleCloseButton"
        
        versionLabel.text = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            if MFMailComposeViewController.canSendMail() {
                let mailVC = MFMailComposeViewController()
                mailVC.mailComposeDelegate = self
                mailVC.setSubject(NSLocalizedString("SVC_FEEDBACK", comment: ""))
                mailVC.setToRecipients([AppConstant.FEEDBACK_EMAIL])
                self.presentViewController(mailVC, animated: true, completion: {})
            } else {
                UIAlertView(title: "",
                    message: NSLocalizedString("SVC_NO_EMAIL", comment: ""),
                    delegate: nil,
                    cancelButtonTitle: NSLocalizedString("SVC_OK", comment: "")).show()
            }
        }
    }
    
    
    func handleCloseButton() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
}
