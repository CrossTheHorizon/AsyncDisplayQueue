//
//  AkExtensions.swift
//  test1
//
//  Created by cn-diss-mac1 on 2018/2/13.
//  Copyright © 2018年 Kodak Alaris. All rights reserved.
//

import UIKit

extension UIView
{
    static var displayID = "cs#DisplayId"
    var DisplayId: AssociatedId!{
        get {
            var value = objc_getAssociatedObject(self, &UIView.displayID) as? AssociatedId
            if value == nil {
                value = AssociatedId()
                objc_setAssociatedObject(self, &UIView.displayID, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
            return value;
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &UIView.displayID, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
}

