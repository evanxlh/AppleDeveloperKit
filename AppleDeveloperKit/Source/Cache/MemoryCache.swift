//
//  MemoryCache.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation

public enum Bytes {
    public static let KB: Int = 1024
    public static let MB: Int = 1048576
    public static let GB: Int = 1073741824
}

/// Convenient memory cache, it can do precise control for maximum memory cost and the count of caching items.
/// From [Nuke ImageCache](https://github.com/kean/Nuke/blob/master/Sources/Core/ImageCache.swift).
///
/// MemoryCache can be set thread safe. Default is not thread safe.
public class MemoryCache<Key, Item> where Key: Hashable {
    
    /// Map stores all nodes, can access node by O(1) if no key conflicts.
    fileprivate var map = [Key: Node<Entry>]()
    fileprivate var list = LinkedList<Entry>()
    fileprivate let lock = MutexLock()
    fileprivate let memoryPressure: DispatchSourceMemoryPressure
    
    fileprivate var _isThreadSafe = true
    fileprivate var _totalCost: UInt = 0
    fileprivate var _costLimit: UInt = 0
    fileprivate var _countLimit: UInt = 0
    fileprivate var _defaulTTL: TimeInterval = 0
    
    /// 0 means no limit.
    public init(costLimit: UInt = 0, countLimit: UInt = 0) {
        _costLimit = costLimit
        _countLimit = countLimit
        memoryPressure = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical], queue: .main)
        memoryPressure.setEventHandler {
            self.removeAll()
        }
        memoryPressure.resume()
    }
    
    deinit {
        memoryPressure.cancel()
        removeAll()
    }
    
}

//MARK: - Public APIs

public extension MemoryCache {
    
    /// Default is thread safe
    var isThreadSafe: Bool {
        get { return _isThreadSafe }
        set { _isThreadSafe = newValue }
    }
    
    /// The maximum total cost that the cache can hold: the number of bytes
    /// - 0 means no limit.
    var costLimit: UInt {
        get {
            return _costLimit
        }
        set {
            guard newValue != _costLimit else { return }
            _costLimit = newValue
            
            if isThreadSafe {
                lock.sync(_trim)
            } else {
                _trim()
            }
        }
    }
    
    /// The maximum number of items that the cache can hold.
    /// - 0 means no limit.
    var countLimit: UInt {
        get {
            return _countLimit
        }
        set {
            guard newValue != _countLimit else { return }
            _countLimit = newValue
            
            if isThreadSafe {
                lock.sync(_trim)
            } else {
                _trim()
            }
        }
    }
    
    /// Default ttl(Time To Live).
    /// - 0 means the cache item will never expire.
    var defaulTTL: TimeInterval {
        get { return _defaulTTL }
        set { _defaulTTL = newValue }
    }
    
    /// The total cost of items in the cache.
    var totalCost: UInt {
        if isThreadSafe {
            return lock.sync({ _totalCost })
        }
        return _totalCost
    }
    
    /// The total number of items in the cache.
    var totalCount: UInt {
        if isThreadSafe {
            return lock.sync({ UInt(map.count) })
        }
        return UInt(map.count)
    }
    
    /// Fetch the item from cahce by key
    func item(forKey key: Key) -> Item? {
        
        let block: () -> Item? = {
            guard let node = self.map[key] else { return nil }
            guard !node.value.isExpired else {
                self._remove(node: node)
                return nil
            }
            
            // Bubble node up to make it last added (most recently used)
            self.list.remove(node)
            self.list.append(node)
            return node.value.value
        }
        
        var target: Item? = nil
        
        if _isThreadSafe {
            lock.sync({
                target = block()
            })
        } else {
            target = block()
        }
        
        return target
    }
    
    /// Cache item to memory
    /// - cost the memory cost in bytes of item.
    /// - ttl: Time To Live in seconds.
    func cacheItem(_ item: Item, forKey key: Key, cost: UInt = 0, ttl: TimeInterval? = nil) {
        let ttl = ttl ?? defaulTTL
        let expiration = ttl == 0 ? nil : (Date() + ttl)
        
        let block = {
            self._add(Entry(value: item, key: key, cost: cost, expiration: expiration))
            self._trim()
        }
        
        if _isThreadSafe {
            lock.sync(block)
        } else {
            block()
        }
    }
    
    /// Remove item from cache by key
    @discardableResult
    func removeItem(forKey key: Key) -> Item? {
        
        let block: () -> Item? = {
            guard let node = self.map[key] else { return nil }
            self._remove(node: node)
            return node.value.value
        }
        
        var target: Item? = nil
        
        if _isThreadSafe {
            lock.sync {
                target = block()
            }
        } else {
            target = block()
        }
        
        return target
    }
    
    /// Remove all items from cache
    func removeAll() {
        let block = {
            self.map.removeAll()
            self.list.removeAll()
            self._totalCost = 0
        }
        
        if _isThreadSafe {
            lock.sync(block)
        } else {
            block()
        }
    }
    
}

//MARK: - Private Assistant Functions

fileprivate extension MemoryCache {
    
    func _add(_ element: Entry) {
        if let existingNode = map[element.key] {
            _remove(node: existingNode)
        }
        map[element.key] = list.append(element)
        _totalCost += element.cost
    }
    
    func _remove(node: Node<Entry>) {
        list.remove(node)
        map[node.value.key] = nil
        _totalCost -= node.value.cost
    }
    
    func _trim() {
        _trim(toCost: _costLimit)
        _trim(toCount: _countLimit)
    }
    
    func _trim(toCost limit: UInt) {
        guard limit > 0 else { return }
        _trim(while: { _totalCost > limit })
    }
    
    func _trim(toCount limit: UInt) {
        guard limit > 0 else { return }
        _trim(while: { UInt(map.count) > limit })
    }
    
    func _trim(while condition: () -> Bool) {
        while condition(), let node = list.head { // Least recently used
            _remove(node: node)
        }
    }
    
}

//MARK: - Private Data Structs

fileprivate extension MemoryCache {
    
    struct Entry {
        let value: Item
        let key: Key
        let cost: UInt
        let expiration: Date?
        
        var isExpired: Bool {
            guard let date = expiration else { return false }
            return date.timeIntervalSinceNow < 0
        }
    }
    
    final class Node<Element> {
        var value: Element
        var previous: Node?
        var next: Node?
        
        init(value: Element) {
            self.value = value
        }
    }
    
    /// An ordered link list
    class LinkedList<Element> {
        var head: Node<Element>?
        var tail: Node<Element>?
        
        var isEmpty: Bool {
            return tail == nil
        }
        
        func insertAtHead(_ node: Node<Element>) {
            if let head = self.head {
                node.next = head
                head.previous = node
                self.head = node
            } else {
                self.head = node
                self.tail = node
            }
        }
        
        @discardableResult
        func append(_ element: Element) -> Node<Element> {
            let node = Node(value: element)
            append(node)
            return node
        }
        
        func append(_ node: Node<Element>) {
            if let tail = self.tail {
                tail.next = node
                node.previous = tail
                self.tail = node
            } else {
                head = node
                tail = node
            }
        }
        
        func moveToHead(_ node: Node<Element>) {
            if head === node { return }
            if tail === node {
                tail = node.previous
                tail?.next = nil
            } else {
                node.previous?.next = node.next
                node.next?.previous = node.previous
            }
            
            node.next = head
            node.previous = nil
            head?.previous = node
            head = node
        }
        
        @discardableResult
        func remove(_ node: Node<Element>) -> Node<Element>? {
            node.previous?.next = node.next
            node.next?.previous = node.previous
            
            if node === tail {
                tail = node.previous
            }
            if node === head {
                head = node.next
            }
            node.next = nil
            node.previous = nil
            
            return node
        }
        
        @discardableResult
        func removeTail() -> Node<Element>? {
            if let tail = self.tail {
                remove(tail)
                return tail
            }
            return nil
        }
        
        func removeAll() {
            var node = head
            while let next = node?.next {
                node?.next = nil
                next.previous = nil
                node = next
            }
        }
    }
    
}

