//
//  WeakObject.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation

public class WeakObject<Object: AnyObject> {
    public weak var object: Object? = nil
    public init(_ object: Object) {
        self.object = object
    }
}
