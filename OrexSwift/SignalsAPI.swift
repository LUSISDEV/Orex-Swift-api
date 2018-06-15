import UIKit
import CryptoSwift

/**
 Signals Delegate allows to implement some methods which are called by API events.
 
 **signalsConnected() method MUST be implemented whereas other methods are optional.**
 
 */
@objc public protocol SignalsDelegate: class {
    func SignalsConnected()
    @objc optional func SignalsDisconnected(reason: String)
    @objc optional func ExpiredSignalsUpdate(data: DATA) // 1183
    @objc optional func NewSignalReceived(data: DATA) // 1181 JUST FOR TESTING
}

public class SignalsAPI: APIBase {
    
    public weak var delegate: SignalsDelegate?
    
    public override init() {
        super.init()
    }
    
    /**
     Connect to the Signals Server.
     
     - Parameter endpoint: address and port server (ex: "ws://192.168.111.222:99999").
     */
    public func connect(endpoint: String) {
        super.connect(name: "SIGNALS", endpoint: endpoint)
    }
    
    /**
     Disconnect from the Signals server
     */
    public func close() {
        super.disconect()
    }
    
    /**
     Logon request sent to Signals Server.
     
     - Parameter login : username
     - Parameter password : user password
     - Returns : A promise which will be performed when API will receive server response.
     */
    public func login(login: String, password: String, version: String, tokenDeviceId: String) -> Promise {
        let bundle = Bundle(identifier: "com.lusis.OrexSwift")
        let apiVersion = bundle?.infoDictionary!["CFBundleShortVersionString"] as! String
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        
        return super.request(data: ["MTI": 1001,
                                    "stationTypeName": "Trader",
                                    "login": login,
                                    "password": password.sha256(),
                                    "osType": 5,
                                    "version":"API-\(apiVersion)-APP-\(appVersion)",
                                    "deviceId": UIDevice.current.modelName,
                                    "guiOs": UIDevice.current.systemName,
                                    "guiOsVersion": UIDevice.current.systemVersion,
                                    "deviceTokenId": tokenDeviceId])
    }
    
    internal override func onConnect() {
        if(devMode) {
            print("[SIGNALS] connected: \(self.socket.url)")
        }
        delegate?.SignalsConnected()
        super.onConnect()
    }
    
    internal override func OnClose(reason: String) {
        if(devMode) {
            print("[SIGNALS] disconnected")
        }
        delegate?.SignalsDisconnected?(reason: reason)
        super.OnClose(reason: reason)
    }
    
    internal override func OnMessage(data : DATA) {
        if data["MTI"] != nil {
            let mti = data["MTI"] as! Int
            switch (mti) {
            case 1183:
                self.delegate?.ExpiredSignalsUpdate?(data: data)
                break
            case 1181:
                self.delegate?.NewSignalReceived?(data: data)
                break
            default:
                break
            }
        }
        else {
            
        }
        super.OnMessage(data: data)
    }
    
    /**
     Signals List request sent to Trade Server.
     
     Promise callbacks have to be implemented for getting data from server.
     
     # Usage Example: #
     ```
     trade.getSignalList(deviceTokenId: "123456789").then(success: {resp in
        print(resp) // print signals list
     }, failure: {reason, resp in
        print(reason)
     })
     ```

     - Returns : A promise which will be performed when API will receive server response.
     */
    public func getSignalList() -> Promise {
        return super.request(data: ["MTI":1180])
    }
    
    
    public func notifyNewOrder(userId: Int, signalId: Int) {
        super.send(data: ["MTI":1182,
                          "userId":userId,
                          "signalId":signalId])
    }
    
}
