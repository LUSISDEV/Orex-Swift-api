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
    var opened: Bool = false
    var name = ""
    var requests: [Int:Promise] = [:]
    var queue : [DATA] = []
    var requestId = 1
    var timer = Timer()

    internal func connect (name: String, endpoint: String) {
        self.name = name
        self.socket = WebSocket()
        self.socket.open(endpoint)
        self.socket.event.open = {self.onConnect()}
        self.socket.event.close = { code, reason, clean in self.OnClose()}
        self.socket.event.message = { message in /*print(message)*/ self.OnMessage(data: self.jsonToDic(data: message))}
        self.socket.event.error = { error in self.onError(error: error)}
    }

    internal func disconect () {
        self.socket.close()
    }

    public func connected () -> Bool {
        return self.opened
    }

    internal func send(data: DATA) {
        self.queue.append(data)
        if !self.timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: (#selector(sendFirstMessage)), userInfo: nil, repeats: false)
        }
    }

    @objc internal func sendFirstMessage(){
        let data = self.queue.removeFirst()
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
        self.opened = true
    }

    internal func OnClose () {
        self.opened = false
        for request in requests {
            request.value.reject(reason: "cancellation", resp: [:])
        }
    }

    internal func OnMessage (data: DATA){
        if (devMode) {
            print("[\(name)] recv: ")
        }
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
