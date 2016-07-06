/**
 The MIT License (MIT)
 
 Copyright (c) 2015 César Ferreira
 Copyright (c) 2015 Pal Dorogi - Implemented in Swift 3.0
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation


public class SwiftEventBus {
    
    struct Static {
        static let instance = SwiftEventBus()
        static let queue = DispatchQueue(label: "com.cesarferreira.SwiftEventBus", attributes: .serial)
    }
    
    struct NamedObserver {
        let observer: NSObjectProtocol
        let name: String
    }
    
    var cache = [UInt:[NamedObserver]]()
    
    
    ////////////////////////////////////
    // Publish
    ////////////////////////////////////
    
    public class func post(name: String) {
        print("XXXXX: \(Notification.Name(rawValue: name))")
        NotificationCenter.default().post(name: Notification.Name(rawValue: name), object: nil)
    }
    
    public class func post(name: String, sender: AnyObject?) {
        NotificationCenter.default().post(name: Notification.Name(rawValue: name), object: sender)
    }
    
    public class func post(name: String, sender: NSObject?) {
        NotificationCenter.default().post(name: Notification.Name(rawValue: name), object: sender)
    }
    
    public class func post(name: String, userInfo: [NSObject : AnyObject]?) {
        NotificationCenter.default().post(name: Notification.Name(rawValue: name), object: nil, userInfo: userInfo)
        //NotificationCenter.default().post(<#T##notification: Notification##Notification#>)
            //.defaultCenter().postNotificationName(name, object: nil, userInfo: userInfo)
    }
    
    public class func post(name: String, sender: AnyObject?, userInfo: [NSObject : AnyObject]?) {
        NotificationCenter.default().post(name: Notification.Name(rawValue: name), object: sender, userInfo: userInfo)
    }
    
    public class func postToMainThread(name: String) {
        DispatchQueue.main.async() {
            NotificationCenter.default().post(name: Notification.Name(rawValue: name), object: nil)
        }
    }
    
    public class func postToMainThread(name: String, sender: AnyObject?) {
        DispatchQueue.main.async() {
            NotificationCenter.default().post(name: Notification.Name(rawValue: name), object: sender)
        }
    }
    
    public class func postToMainThread(name: String, sender: NSObject?) {
        DispatchQueue.main.async() {
            NotificationCenter.default().post(name: Notification.Name(rawValue: name), object: sender)
        }
    }
    
    public class func postToMainThread(name: String, userInfo: [NSObject : AnyObject]?) {
        DispatchQueue.main.async() {
            NotificationCenter.default().post(name: Notification.Name(rawValue: name), object: nil, userInfo: userInfo)
        }
    }
    
    public class func postToMainThread(name: String, sender: AnyObject?, userInfo: [NSObject : AnyObject]?) {
        DispatchQueue.main.async() {
            NotificationCenter.default().post(name: Notification.Name(rawValue: name), object: sender, userInfo: userInfo)
        }
    }
    
    
    
    ////////////////////////////////////
    // Subscribe
    ////////////////////////////////////
    
    public class func on(target: AnyObject, name: String, sender: AnyObject?, queue: OperationQueue?, handler: ((Notification) -> Void)) -> NSObjectProtocol {
        let id = UInt(ObjectIdentifier(target))
        
        // let observer = NotificationCenter.default().addObserver(forName: name, object: sender, queue: queue, usingBlock: handler)

        ///let observer = NotificationCenter.defaultCenter().addObserverForName(name, object: sender, queue: queue, usingBlock: handler)
        let observer = NotificationCenter.default().addObserver(forName: Notification.Name(rawValue: name), object: sender, queue: queue, using: handler)
        let namedObserver = NamedObserver(observer: observer, name: name)
        
        Static.queue.sync() {
            if let namedObservers = Static.instance.cache[id] {
                Static.instance.cache[id] = namedObservers + [namedObserver]
            } else {
                Static.instance.cache[id] = [namedObserver]
            }
        }
        
        return observer
    }
    
    public class func onMainThread(target: AnyObject, name: String, handler: ((Notification!) -> Void)) -> NSObjectProtocol {
        return SwiftEventBus.on(target: target, name: name, sender: nil, queue: OperationQueue.main(), handler: handler)
    }
    
    public class func onMainThread(target: AnyObject, name: String, sender: AnyObject?, handler: ((Notification!) -> Void)) -> NSObjectProtocol {
        return SwiftEventBus.on(target: target, name: name, sender: sender, queue: OperationQueue.main(), handler: handler)
    }
    
    public class func onBackgroundThread(target: AnyObject, name: String, handler: ((Notification!) -> Void)) -> NSObjectProtocol {
        return SwiftEventBus.on(target: target, name: name, sender: nil, queue: OperationQueue(), handler: handler)
    }
    
    public class func onBackgroundThread(target: AnyObject, name: String, sender: AnyObject?, handler: ((Notification!) -> Void)) -> NSObjectProtocol {
        return SwiftEventBus.on(target: target, name: name, sender: sender, queue: OperationQueue(), handler: handler)
    }
    
    ////////////////////////////////////
    // Unregister
    ////////////////////////////////////
    
    public class func unregister(target: AnyObject) {
        let id = UInt(ObjectIdentifier(target))
        let center = NotificationCenter.default()
        
        Static.queue.sync() {
            if let namedObservers = Static.instance.cache.removeValue(forKey: id) {
                for namedObserver in namedObservers {
                    center.removeObserver(namedObserver.observer)
                }
            }
        }
    }
    
    public class func unregister(target: AnyObject, name: String) {
        let id = UInt(ObjectIdentifier(target))
        let center = NotificationCenter.default()
        
        Static.queue.sync() {
            if let namedObservers = Static.instance.cache[id] {
                Static.instance.cache[id] = namedObservers.filter({ (namedObserver: NamedObserver) -> Bool in
                    if namedObserver.name == name {
                        center.removeObserver(namedObserver.observer)
                        return false
                    } else {
                        return true
                    }
                })
            }
        }
    }
    
}
