//
//  DetektorActivity.swift
//  Detektor
//
//  Created by Cássio Marcos Goulart on 15/06/19.
//  Copyright © 2019 CMG Solutions. All rights reserved.
//

import UIKit

class DetektorActivity: UIActivity {

    static let activityType: UIActivity.ActivityType = UIActivity.ActivityType(rawValue: "com.cmg.detektor.activity")
    
    private var _activityTitle: String
    private var _activityImage: UIImage?
    private var activityItems = [Any]()
    private var action: ([Any]) -> Void
    
    init(title: String, image: UIImage?, performAction: @escaping ([Any]) -> Void) {
        _activityTitle = title
        _activityImage = image
        action = performAction
        super.init()
    }
    
    override var activityTitle: String? {
        return _activityTitle
    }
    
    override var activityImage: UIImage? {
        return _activityImage
    }
    
    override var activityType: UIActivity.ActivityType? {
        return DetektorActivity.activityType
    }
    
    override class var activityCategory: UIActivity.Category {
        return .action
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        self.activityItems = activityItems
    }
    
    override func perform() {
        action(activityItems)
        activityDidFinish(true)
    }
    
}
