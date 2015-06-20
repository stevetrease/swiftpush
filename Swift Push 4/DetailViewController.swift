//
//  DetailViewController.swift
//  Swift Push 4
//
//  Created by Steve Trease on 16/06/2015.
//  Copyright © 2015 Steve Trease. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var messageIDLabel: UILabel!
    @IBOutlet weak var timeStampSentLabel: UILabel!
    @IBOutlet weak var timeStampReceivedLabel: UILabel!
    @IBOutlet weak var latencyLabel: UILabel!


    var detailItem: NotificationData? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    
    // func configureView() {
        // Update the user interface for the detail item.
    //     if let detail = self.detailItem {
    //         if let label = self.detailDescriptionLabel {
    //            label.text = detail.description
    //        }
    //    }
    // }

    
    
    func configureView() {
        if let notification = self.detailItem {
         
            if let label = self.alertLabel {
                label.text = notification.alert
            }
            if let label = self.messageIDLabel {
                label.text = "\(notification.messageID)"
            }
            if let label = self.timeStampSentLabel {
                label.text = NSDateFormatter.localizedStringFromDate(notification.timeStampSent, dateStyle: .MediumStyle, timeStyle: .ShortStyle) as String
            }
            if let label = self.timeStampReceivedLabel {
                label.text = NSDateFormatter.localizedStringFromDate(notification.timeStampReceived, dateStyle: .MediumStyle, timeStyle: .ShortStyle) as String
            }
            if let label = self.latencyLabel {
                let components = NSCalendar.currentCalendar().components(.CalendarUnitSecond |
                    .CalendarUnitMinute | .CalendarUnitHour | .CalendarUnitDay |
                    .CalendarUnitMonth | .CalendarUnitYear, fromDate: notification.timeStampSent,
                    toDate: notification.timeStampReceived, options: nil)
                let dateComponentsFormatter = NSDateComponentsFormatter()
                dateComponentsFormatter.includesApproximationPhrase = true
                dateComponentsFormatter.unitsStyle = .Abbreviated
                label.text = dateComponentsFormatter.stringFromDateComponents(components)
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

