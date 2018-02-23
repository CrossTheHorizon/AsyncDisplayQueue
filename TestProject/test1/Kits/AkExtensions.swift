//
//  AkExtensions.swift
//  test1
//
//  Created by AaronZhang on 2018/2/13.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

import UIKit

class AssociatedId
{
    var id = 0;
}

extension UIView
{
    private static var kAssociatedId = "cs#AssociatedId"
    var DisplayId: AssociatedId!{
        get {
            var value = objc_getAssociatedObject(self, &UIView.kAssociatedId) as? AssociatedId
            if value == nil {
                value = AssociatedId()
                objc_setAssociatedObject(self, &UIView.kAssociatedId, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
            return value;
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &UIView.kAssociatedId, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
}

extension NSData
{
    
}
