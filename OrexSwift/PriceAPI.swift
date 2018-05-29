import UIKit

/**
 Price Delegate allows to implement some methods which are called by API events.

 **priceConnected() method MUST be implemented whereas other methods are optional.**
 
*/
@objc public protocol PriceDelegate: class {
    @objc func priceConnected()
    @objc optional func priceDisconnected(reason: String)
    @objc optional func ChangeAccountResponse(data: DATA)
    @objc optional func SubscribeFXResponse(data: DATA)
    @objc optional func UnsubscribeFXResponse(data: DATA)
    @objc optional func SubscribeCFDResponse(data: DATA)
    @objc optional func UnsubscribeCFDResponse(data: DATA)
    @objc optional func SubscribeSBResponse(data: DATA)
    @objc optional func UnsubscribeSBResponse(data: DATA)
}

public class PriceAPI: APIBase {
    private struct Subscription {
        var cb: (DATA)->()
        var id: Int!
        var owner: NSObject!
    }

    public weak var delegate: PriceDelegate?
    private var subscriptions: [Int:[Subscription]] = [:]
    private var subQueue: [DATA] = []
    private var prices: [Int:DATA] = [:]
    private var instrumentsType: [Int:String] = [:]
    private var priceTimer = Timer()

    public override init() {
        super.init()
    }

    /**
     Connect to the Price server
     
     # Usage Example: #
     ```
     price.connect(endpoint: "ws://192.168.111.222:12345")
     ```
     The response is received in priceConnected event that must be implemented.
     ```
     func priceConnected() {
      // do something
     }
     ```
     
     - Parameter endpoint: address and port server (ex: "ws://192.168.111.222:12345")
    */
    public func connect(endpoint: String) {
        super.connect(name: "PRICE", endpoint: endpoint)
    }

    /**
     Disconnect from the Price server
     
     # Usage Example: #
     ```
     price.close()
     ```
     The response is received in priceDisconnected event that can be implemented.
     ```
     func priceDisconnected() {
     // do something
     }
     ```
    */
    public func close() {
        if (self.priceTimer.isValid) {
            self.priceTimer.invalidate()
        }
        self.subscriptions = [:]
        self.subQueue = []
        self.prices = [:]
        self.disconect()
    }

    /**
     Logon request sent to Price Server.
     
     # Usage Example: #
     ```
     price.login(userId: 20).then(success: {resp in
        print(resp) // Login response
     }, failure: {reason, resp in
        print(reason)
     })
     ```
     - Parameter userId: User ID
     - Returns : A promise which will be performed when API will receive server response.
     */
    public func login(userId: Int) -> Promise {
        return super.request(data: ["MTI": 5008,
                                    "userId": userId,])
    }

    /**
     Change account request sent to Price Server.
     
     # Usage Example: #
     ```
     price.changeAccount(accNumber: "123456789")
     ```
     The response is received in ChangeAccountResponse event that you can implement.
     ```
     func ChangeAccountResponse(data: DATA) {
        print(data)
     }
     ```
     - Parameter accNumber: Client account number.
     */
    public func changeAccount(accNumber: String) {
        super.request(data: ["MTI": 5013, "accountNumber": accNumber]).then(success:
            {
                resp in
                var arr : [String:[DATA]] = ["FX":[],
                                             "CFD":[],
                                             "SB":[]]

                let streamList : [String:Int] = ["FX":1,
                                                 "CFD":80,
                                                 "SB":160]

                let mtiList : [String:Int] = ["FX":5010,
                                              "CFD":5210,
                                              "SB":5510]

                for sub in self.subscriptions {
                    if self.instrumentsType[sub.key] != nil {
                        arr[self.instrumentsType[sub.key]!]?.append(["instrumentId":sub.key, "streamType": streamList[self.instrumentsType[sub.key]!]!])
                    }
                }
                for instrumentList in arr {
                    if instrumentList.value.count > 0 {
                        self.send(data: ["MTI": mtiList[instrumentList.key]!, "instrumentList": instrumentList.value])
                    }
                }

             }, failure: {_, _ in })
    }
    
    private func livePrice(insid: Int) -> DATA{
        return (self.prices[insid] != nil) ? self.prices[insid]! : self.initPrice(id: insid)
    }

    private func enqueue(sub: DATA) {
        self.subQueue.append(sub)
        if (!priceTimer.isValid) {
            priceTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: (#selector(subscribeToQueuedInstruments)), userInfo: nil, repeats: false)
        }
    }

    @objc private func subscribeToQueuedInstruments() {
        let streamList : [String:Int] = ["FX":1,
                                        "CFD":80,
                                        "SB":160]

        let unMtiList : [String:Int] = ["FX":5012,
                                        "CFD":5212,
                                        "SB":5512]

        let mtiList : [String:Int] = ["FX":5010,
                                      "CFD":5210,
                                      "SB":5510]

        var subs: [Int:Int] = [:]

        for sub in self.subQueue {
            if instrumentsType[sub["insid"] as! Int] == nil {
                instrumentsType[sub["insid"] as! Int] = (sub["type"] as! String)
            }
            subs[sub["insid"] as! Int] = subs[sub["insid"] as! Int] != nil ? subs[sub["insid"] as! Int] : 0
            subs[sub["insid"] as! Int] = subs[sub["insid"] as! Int]! + ((sub["sub"] as! Int) == 0 ? -1 : 1)
        }
        self.subQueue = []
        var instrumentLists : [String:[DATA]] = ["FX":[],
                                                 "CFD":[],
                                                 "SB":[]]

        for ins in subs {
            if(ins.value <= 0) {
                if instrumentsType[ins.key] != nil {
                    let insType : String = instrumentsType[ins.key]!
                    let streamType : Int = streamList[insType]!
                    let newDic : DATA = ["instrumentId": ins.key, "streamType": streamType]
                    instrumentLists[insType]?.append(newDic)
                }
            }
        }
        for insType in unMtiList {
            if instrumentLists[insType.key]!.count > 0 {
                self.send(data: ["MTI": insType.value, "instrumentList": instrumentLists[insType.key]!])
            }
        }

        instrumentLists = ["FX":[],
                           "CFD":[],
                           "SB":[]]

        for ins in subs {
            if(ins.value >= 1) {
                if instrumentsType[ins.key] != nil {
                    let insType : String = instrumentsType[ins.key]!
                    let streamType : Int = streamList[insType]!
                    let newDic : DATA = ["instrumentId": ins.key, "streamType": streamType]
                    instrumentLists[insType]?.append(newDic)
                }
            }
        }
        var i = 0.0
        for insType in mtiList {
            if instrumentLists[insType.key]!.count > 0 {
                let data = ["MTI": insType.value, "instrumentList": instrumentLists[insType.key]!] as [String : Any]
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + i) {
                    self.send(data: data)
                }
                i+=0.1
            }
        }

        self.priceTimer.invalidate()
    }

    /**
     Subscribe to an instrument
     
     # Usage Example: #
     ```
     // A first call back is attributed to the instrument which has 25 as instrument ID
     price.subscribe(insid: 25, cb: {
        print("Hello from instrument 25")
     }, instrumentType: "FX", id: 1, owner: self)
     
     // A first call back is attributed to the instrument which has 25 as instrument ID
     price.subscribe(insid: 25, cb: {
        print("Another hello from instrument 25")
     }, instrumentType: "FX", id: 2, owner: self)
     
     // The second callback is cancelled by using unsubscribe method. The first call back is still running
     price.unsubscribe(insid: 25, id: 2, owner: self)
     
     ```
     - Parameter insid : instrument ID of the instrument we want to subscribe
     - Parameter cb : the callback that will be performed when API will receive notification for the choosen instrument
     - Parameter instrumentType : instrumentType FX, CFD, SB
     - Parameter id : an id to identify the callback.
     - Parameter owner : to check if the one which subscribe is the same which try to unsubscribe
     
     An id is necessary for each callback to allow to cancel just one or more callback with the same instrument id and not all the callbacks associated with this instrument id
    */
    public func subscribe(insid: Int, cb: @escaping (DATA)->(), instrumentType: String, id: Int, owner: NSObject) {
        if(self.subscriptions[insid] == nil) {
            self.subscriptions[insid] = []
        }
        self.subscriptions[insid]?.append(Subscription(cb: cb, id: id, owner: owner))
        if(self.subscriptions[insid]?.count == 1) {
            self.enqueue(sub: ["insid": insid, "sub": 1, "type": instrumentType])
        }
    }

    /**
     Unsubscribe from an instrument
     
     # Usage Example: #
     ```
     // A first call back is attributed to the instrument which has 25 as instrument ID
     price.subscribe(insid: 25, cb: {
     print("Hello from instrument 25")
     }, instrumentType: "FX", id: 1, owner: self)
     
     // A first call back is attributed to the instrument which has 25 as instrument ID
     price.subscribe(insid: 25, cb: {
     print("Another hello from instrument 25")
     }, instrumentType: "FX", id: 2, owner: self)
     
     // The second callback is cancelled by using unsubscribe method. The first call back is still running
     price.unsubscribe(insid: 25, id: 2, owner: self)
     
     ```
     
     - Parameter insid : instrument ID of the instrument we want to unsubscribe
     - Parameter id : an id to identify the callback we want to unsubscribe
     - Parameter owner : to check if the one which subscribe is the same which try to unsubscribe
     
     An id is necessary for each callback to allow to cancel just one or more callback with the same instrument id and not all the callbacks associated with this instrument id
     */
    public func unsubscribe(insid: Int, id: Int, owner: NSObject) {
        if(self.subscriptions[insid] != nil) {
            self.subscriptions[insid]! = self.subscriptions[insid]!.filter {!($0.id == id && $0.owner == owner)}
            if self.subscriptions[insid]!.count == 0 {
                self.subscriptions.removeValue(forKey: insid)
                self.enqueue(sub: ["insid":insid, "sub": 0])
            }
        }
    }

    private func handlePriceUpdate(data: DATA) {
        if(self.prices[data["instrumentId"] as! Int] == nil) {
            self.prices[data["instrumentId"] as! Int] = self.initPrice(id: data["instrumentId"] as! Int)
        }
        var price: DATA = self.prices[data["instrumentId"] as! Int]!
        if(data["bandList"] != nil && (data["bandList"] as! [DATA]).count > 0 ) {
            let bid = (data["bandList"] as! [DATA])[0]["bidRate"] as! String
            let ask = (data["bandList"] as! [DATA])[0]["askRate"] as! String
            let bidTrend = Float(bid)! > Float(price["bid"] as! Int) ? 1 : Float(bid)! < Float(price["bid"] as! Int) ? -1 : 0
            let askTrend = Float(ask)! < Float(price["ask"] as! Int) ? 1 : Float(ask)! > Float(price["ask"] as! Int) ? -1 : 0
            price["bid"] = bid
            price["bidTradable"] = (data["bandList"] as! [DATA])[0]["bidTradable"]
            price["bidTrend"] = bidTrend
            price["ask"] = ask
            price["askTradable"] = (data["bandList"] as! [DATA])[0]["askTradable"]
            price["askTrend"] = askTrend
        }
        else {
            price["bidTradable"] = 0
            price["askTradable"] = 0
            price["bidTrend"] = 0
            price["askTrend"] = 0
        }
        if(self.subscriptions[data["instrumentId"] as! Int] != nil) {
            let subs: [Subscription] = self.subscriptions[data["instrumentId"] as! Int]!

            for sub in subs {
                sub.cb(data)
            }
        }
    }

    private func initPrice(id: Int) -> DATA {
        return ["insid":id,
                "ask":0,
                "bid":0,
                "high":0,
                "low":0,
                "askTrend":0,
                "bidTrend":0,
                "askTradable":0,
                "bidTradable":0,
                "askValueDate":"",
                "bidValueDate":""]
    }

    internal override func onConnect() {
        if(devMode) {
            print("[PRICE] connected: \(self.socket.url)")
        }
        delegate?.priceConnected()
        super.onConnect()
    }

    internal override func OnClose(reason: String) {
        if(devMode) {
            print("[PRICE] disconnected")
        }
        delegate?.priceDisconnected?(reason: reason)
        super.OnClose(reason: reason)
    }

    internal override func OnMessage(data : DATA) {
        if data["MTI"] != nil {
            let mti = data["MTI"] as! Int
            switch (mti) {
            case 5013:
                self.delegate?.ChangeAccountResponse?(data: data)
                break
            case 5010:
                self.delegate?.SubscribeFXResponse?(data: data)
                break
            case 5012:
                self.delegate?.UnsubscribeFXResponse?(data: data)
                break
            case 5210:
                self.delegate?.SubscribeCFDResponse?(data: data)
                break
            case 5212:
                self.delegate?.UnsubscribeCFDResponse?(data: data)
                break
            case 5510:
                self.delegate?.SubscribeSBResponse?(data: data)
                break
            case 5512:
                self.delegate?.UnsubscribeSBResponse?(data: data)
                break
            case 3000, 3200, 3500:
                let netData = data["netData"]
                if netData != nil {
                    let marketData = MarketData()
                    let instrumentList = marketData.decode(buffer: Array<Character>(netData as! String))
                    for instrument in instrumentList {
                        self.handlePriceUpdate(data: instrument)
                    }
                }
                else {
                    let instrumentList = data["instrumentList"] as! [DATA]
                    for instrument in instrumentList {
                        self.handlePriceUpdate(data: instrument)
                    }
                }
                break
            default:
                break
            }
        }
        super.OnMessage(data: data)
    }

}


