//
//  WeakObjects.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation

public class WeakObject<T: AnyObject> {
    public weak var object: T? = nil
    public init(_ object: T) {
        self.object = object
    }
}

public class WeakObjects<T> where T: AnyObject {

    fileprivate var _objects = [WeakObject<T>]()
    fileprivate var lock = MutexLock()

    public init() { }

    public var objects: [T] {
        return _objects.compactMap({ $0.object })
    }

    public var count: Int {
        return objects.count
    }

    public func addObject(_ object: T) {
        lock.sync({
            self._objects.append(WeakObject(object))
        })
    }

    public func removeObject(_ object: T) {
        let index = _objects.firstIndex { $0.object === object }
        guard let removeIndex = index else { return }
        lock.sync({ self._objects.remove(at: removeIndex) })
    }

    public func removeAll() {
        lock.sync({ self._objects.removeAll() })
    }

}
