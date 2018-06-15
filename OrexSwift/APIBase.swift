
import UIKit
import SwiftWebSocket
import Foundation

let devMode = false

public typealias DATA = [String:Any]

public class Promise {
    private var success : ( _ resp : DATA ) -> () = { resp in }
    private var failure : ( _ reason : String, _ resp : DATA ) -> () = { reason, resp in }
    internal func resolve(resp: DATA) {
        success(resp)
    }

    internal func reject(reason: String, resp : DATA) {
        failure(reason, resp)
    }
 
    public func then(success: @escaping ((_ resp: DATA) -> ()), failure: @escaping ((_ reason: String, _ resp : DATA) -> ())) {
        self.success = {resp in success(resp)}
        self.failure = {reason, resp in failure(reason, resp)}
    }
}

public class APIBase {
    
    var showLogs: Bool = false
    
    var resultCodes: [Int:String] = [1003: "Invalid MTI",
                                     1004: "Already connected",
                                     1005: "Not connected",
                                     1006: "Wrong login",
                                     1007: "Wrong password",
                                     1008: "No connection tries left",
                                     1009: "Account disabled",
                                     1010: "Insufficient rights",
                                     1011: "Account rights failed",
                                     1012: "Wrong version",
                                     1013: "Control failed",
                                     1014: "Must change password",
                                     1015: "Invalid new password",
                                     5000: "Invalid old password",
                                     2104: "Technical error abort",
                                     2105: "Technical error routing"]

    var theQueue : [DATA] = []

    var socket: WebSocket!
    var open: Bool = false
    var name = ""
    var requests: [Int:Promise] = [:]
    var queue : [DATA] = []
    var requestId = 1
    var timer = Timer()
    
    public func showLogs(show: Bool) {
        self.showLogs = show
    }
    
    func printLog(object: Any) {
        if self.showLogs == true {
            print(object)
        }
    }

    internal func connect (name: String, endpoint: String) {
        self.name = name
        self.socket = WebSocket()
        self.socket.open(endpoint)
        self.socket.event.open = {self.onConnect()}
        self.socket.event.close = { code, reason, clean in self.OnClose(reason: reason)}
        self.socket.event.message = { message in /*print(message)*/ self.OnMessage(data: self.jsonToDic(data: message))}
        self.socket.event.error = { error in self.onError(error: error)}
    }

    internal func disconect () {
        self.socket.close()
    }

    public func connected () -> Bool {
        return self.open
    }

    internal func send(data: DATA) {
        self.queue.append(data)
        if !self.timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: (#selector(sendFirstMessage)), userInfo: nil, repeats: false)
        }
    }

    @objc internal func sendFirstMessage(){
        let data = self.queue.removeFirst()
        printLog(object: "\n################### SENDING ###################")
        printLog(object: data)
        printLog(object: "###############################################\n")
        self.socket.send(data: self.dicToJson(data: data))
        if self.queue.count == 0 {
            self.timer.invalidate()
        }
        else {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: (#selector(sendFirstMessage)), userInfo: nil, repeats: false)
        }
    }

    internal func request (data: [String: Any]) -> Promise {
        let promise = Promise()
        requests[requestId] = promise
        var msg = data
        msg["messageId"] = requestId
        requestId += 1
        self.send(data: msg)
        return promise
    }

    internal func onConnect () {
        self.open = true
    }

    internal func OnClose (reason: String) {
        self.open = false
        for request in requests {
            request.value.reject(reason: "cancellation", resp: [:])
        }
    }

    internal func OnMessage (data: DATA){
        if (devMode) {
            print("[\(name)] recv: ")
        }
        printLog(object: "\n################### RECEIVING ###################")
        printLog(object: data)
        printLog(object: "##################################################\n")
        if (data["messageId"] != nil && (self.requests[data["messageId"] as! Int] != nil)) {
            let promise: Promise = self.requests[data["messageId"] as! Int]!
            var msg = data
            requests.removeValue(forKey: data["messageId"] as! Int)
            msg.removeValue(forKey: "messageId")
            let resultCode = data["resultCode"] as! Int
            if  resultCode == 0 {
                promise.resolve(resp: msg)
            }
            else {
                resultCodes[resultCode] != nil ? promise.reject(reason: resultCodes[resultCode]!, resp: msg) : promise.reject(reason: "unknown reason", resp: msg)
            }
            
        }

    }

    internal func onError (error: Error) {
        print("error \(error)")
    }

    private func jsonToDic (data: Any) -> DATA {
        var json: DATA = [:]
        do {
            json = try JSONSerialization.jsonObject(with: (data as! String).data(using: .utf8)!, options: []) as! DATA
        }
        catch { print(error) }

        return json
    }

    private func dicToJson (data: DATA) -> Data {
        var jsonData = Data()
        do {
            jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        }
        catch { print(error) }

        return jsonData
    }
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad7,5", "iPad7,6":                      return "iPad 6"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return "Other device"
        }
    }
}
