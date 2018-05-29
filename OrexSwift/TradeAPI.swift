import UIKit
import CryptoSwift

/**
 Trade Delegate allows to implement some methods which are called by API events.
 
 **tradeConnected() method MUST be implemented whereas other methods are optional.**
 
 */
@objc public protocol TradeDelegate: class {
    func tradeConnected()
    @objc optional func tradeDisconnected(reason: String)
    @objc optional func TopAccountSummary(data: DATA) // 6000
    @objc optional func AccountSummaryRetailUpdate(data: DATA) // 4005
    @objc optional func AccountSummaryUpdate(data: DATA) // 4000
    @objc optional func PositionUpdate(data: DATA) // 1005
    @objc optional func TicketListRetailUpdate(data: DATA) // 1011
    @objc optional func OrderUpdate(data: DATA) // 6000
    @objc optional func AlertMessage(data: DATA) // 1320 1321 4010
    @objc optional func NewSignalReceived(data: DATA) // 1181
    @objc optional func ExpiredSignalsUpdate(data: DATA) // 1183
}

public class TradeAPI: APIBase {

    public weak var delegate: TradeDelegate?

    public override init() {
        super.init()
    }

    /**
     Connect to the Trade Server.
     
     - Parameter endpoint: address and port server (ex: "ws://192.168.111.222:99999").
    */
    public func connect(endpoint: String) {
        super.connect(name: "TRADE", endpoint: endpoint)
    }

    /**
     Disconnect from the Trade server
     */
    public func close() {
        super.disconect()
    }

    /**
     Logon request sent to Price Server.
     
     - Parameter login : username
     - Parameter password : user password
     - Returns : A promise which will be performed when API will receive server response.
     */
    public func login(login: String, password: String, version: String) -> Promise {
        
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
                                    "guiOsVersion": UIDevice.current.systemVersion])
    }

    internal override func onConnect() {
        if(devMode) {
            print("[TRADE] connected: \(self.socket.url)")
        }
        delegate?.tradeConnected()
        super.onConnect()
    }

    internal override func OnClose(reason: String) {
        if(devMode) {
            print("[TRADE] disconnected")
        }
        delegate?.tradeDisconnected?(reason: reason)
        super.OnClose(reason: reason)
    }

    internal override func OnMessage(data : DATA) {
        if data["MTI"] != nil {
            let mti = data["MTI"] as! Int
            switch (mti) {
            case 4012:
                self.delegate?.TopAccountSummary?(data: data)
                break
            case 4000:
                self.delegate?.AccountSummaryUpdate?(data: data)
                break
            case 4005:
                self.delegate?.AccountSummaryRetailUpdate?(data: data)
                break
            case 1005:
                self.delegate?.PositionUpdate?(data: data)
                break
            case 1011:
                self.delegate?.TicketListRetailUpdate?(data: data)
                break
            case 1320, 1321, 4010:
                self.delegate?.AlertMessage?(data: data)
                break
            case 6000:
                self.delegate?.OrderUpdate?(data: data)
                break
            case 1181:
                self.delegate?.NewSignalReceived?(data: data)
                break
            case 1183:
                self.delegate?.ExpiredSignalsUpdate?(data: data)
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
     Client and Account List request sent to Trade Server.
     
     Promise callbacks have to be implemented for getting data from server.
     
     # Usage Example: #
     ```
     trade.getAccountList().then(success: {resp in
        print(resp) // print accounts list
     }, failure: {reason, resp in
        print(reason)
     })
     ```
    
     - Returns : A promise which will be performed when API will receive server response.
     */
    public func getAccountList () -> Promise {
        return super.request(data: ["MTI": 1031])
    }

    /**
     Forex List request sent to Trade Server.
     
     Promise callbacks have to be implemented for getting data from server.
     
     # Usage Example: #
     ```
     trade.getFXList().then(success: {resp in
        print(resp) // print FX instruments list
     }, failure: {reason, resp in
        print(reason)
     })
     ```
    
     - Returns : A promise which will be performed when API will receive server response.
    */
    public func getFXList () -> Promise {
        return super.request(data: ["MTI": 1002,
                                    "category": "FX"])
        
        
    }

    
    /**
     CFD List request sent to Trade Server.
     
     Promise callbacks have to be implemented for getting data from server.
     
     # Usage Example: #
     ```
     trade.getCFDList().then(success: {resp in
        print(resp) // print CFD instruments list
     }, failure: {reason, resp in
        print(reason)
     })
     ```
     
     - Parameter lastSBUpdate : YYYYMMDDHHMMSS (Optional).
     - Returns : A promise which will be performed when API will receive server response.
    */
    public func getCFDList (lastCFDUpdate: String = "") -> Promise { // format YYYYMMDDHHMMSS
        var data: DATA = ["MTI": 1202]
        if lastCFDUpdate != "" {
            data["lastCFDUpdate"] = lastCFDUpdate
        }
        return super.request(data: data)
    }

    /**
     SB List request sent to Trade Server.
     
     Promise callbacks have to be implemented for getting data from server.
     
     # Usage Example: #
     ```
     trade.getSBList().then(success: {resp in
        print(resp) // print SB instruments list
     }, failure: {reason, resp in
        print(reason)
     })
     ```
     
     - Parameter lastSBUpdate : YYYYMMDDHHMMSS (Optional).
     - Returns : A promise which will be performed when API will receive server response.
    */
    public func getSBList (lastSBUpdate: String = "") -> Promise { // format YYYYMMDDHHMMSS
        var data: DATA = ["MTI": 1302]
        if lastSBUpdate != "" {
            data["lastSBUpdate"] = lastSBUpdate
        }
        return super.request(data: data)
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
     
     - Parameter deviceTokenId : iOS device token
     - Returns : A promise which will be performed when API will receive server response.
    */
    public func getSignalList (deviceTokenId: String) -> Promise {
        return super.request(data: ["MTI":1180,
                                    "deviceTokenId": deviceTokenId])
    }

    /**
     Account summary request sent to Trade Server.
     
     # Usage Example: #
     ```
     trade.getAccountSummaryRetail(accNumber: "123456789")
     ```
     
     The response is received in AccountSummaryRetailUpdate event that you can implement.
     ```
     func AccountSummaryRetailUpdate(data: DATA) {
        print(data)
     }
     ```
     
     - Parameter accNumber : account number (for gross mode).
    */
    public func getAccountSummaryRetail (accNumber: String) {
        super.send(data: ["MTI": 4005, "accountNumber": accNumber])
    }

    /**
     Account summary request sent to Trade Server.
     
     ## Only for an account summary in gross mode (single account). ##

     # Usage Example: #
     ```
     trade.getAccountSummary(accNumber: "123456789")
     ```
     The response is received in AccountSummaryUpdate event that you can implement.
     ```
     func AccountSummaryUpdate(data: DATA) {
        print(data)
     }
     ```
     
     - Parameter accNumber : account number (for gross mode).
    */
    public func getAccountSummary (accNumber: String) {
        super.send(data: ["MTI": 4000, "accountNumber": accNumber])
    }

    /**
     Account summary request sent to Trade Server.
     
     ## Only for getting a net view of all the accounts (net mode) ##
     
     # Usage Example: #
     ```
     trade.getAccountSummary(dosId: 0)
     ```
     The response is received in AccountSummaryUpdate event that you can implement.
     ```
     func AccountSummaryUpdate(data: DATA) {
        print(data)
     }
     ```
     
     - Parameter dosId : dossier id
    */
    public func getAccountSummary (dosId: Int) {
        super.send(data: ["MTI": 4000, "dosId": dosId])
    }
    
    /**
     Positions list request sent to Trade Server.
     
     # Usage Example: #
     ```
     trade.getPositions(accNumber: "123456789", instrumentType: "FX")
     ```
     The response is received in PositionUpdate event that you can implement.
     ```
     func PositionUpdate(data: DATA) {
        print(data)
     }
     ```
     
     - Parameter accNumber : Client account number
     - Parameter instrumentType : FX, CFD, SB
    */
    public func getPositions (accNumber: String, instrumentType: String) {
        self.send(data: ["MTI": 1005,
                         "accountNumber": accNumber,
                         "instrumentType": instrumentType])
    }

    
    /**
     Positions list request sent to Trade Server.
     
     ## This method send the same request as getPositions(accNumber: String, instrumentType: String) but received the response in a promise and not in an event. ##
     
     # Usage Example: #
     ```
     trade.getPositions(accNumber: "123456789", instrumentType: "FX").then(success: {resp in
        print(resp) // print positions list
     }, failure: {reason, resp in
        print(reason)
     })
     ```

     - Parameter accNumber : Client account number
     - Parameter instrumentType : FX, CFD, SB
     - Returns : A promise which will be performed when API will receive server response.
    */
    public func getPositionsReq (accNumber: String, instrumentType: String) -> Promise {
        return self.request(data: ["MTI": 1005,
                                   "accountNumber": accNumber,
                                   "instrumentType": instrumentType])
    }

    /**
     Charts Data request sent to Trade Server.
    
     # Usage Example: #
     ```
     trade.requestChartsData(accNumber: "123456789", instrumentType: "FX", insId: "1", beginDate: "201801011200", endDate: "201801021200", period: "1D").then(success: {resp in
     print(resp) // print charts data
     }, failure: {reason, resp in
        print(reason)
     })
     ```
     
     - Parameter accNumber : Client account number
     - Parameter instrumentType : FX, CFD, SB
     - Parameter insId : Instrument ID from Instrument List response
     - Parameter beginDate : YYYYMMDDHHmm
     - Parameter endDate : YYYYMMDDHHmm
     - Parameter period : Chart time scale
         ```
         1M  : 1 minute
         5M  : 5 minutes
         15M : 15 minutes
         1H  : 1 hour
         4H  : 4 hours
         1D  : 1 day
         ```
     
     - Returns : A promise which will be performed when API will receive server response.
     */
    public func requestChartsData (accNumber: String, instrumentType: String, insId: String, beginDate: String, endDate: String, period: String) -> Promise {
        return self.request(data: ["MTI": 1100,
                                   "instrumentType": instrumentType,
                                   "instrumentId": insId,
                                   "chartStartDateTime": beginDate,
                                   "chartEndDateTime": endDate,
                                   "chartTimeScale": period,
                                   "accountNumber": accNumber])
    }

    /**
     Working order list request sent to Trade Server.
     
     # Usage Example: #
     ```
     trade.getWorkingOrderList(instrumentType: "FX", accNumber: "123456789", customerOrderId: "111", startPage: 1, endPage: 1).then(success: {resp in
        print(resp) // print working order list
     }, failure: {reason, resp in
        print(reason)
     })
     ```
     - Parameter accNumber : Client account number
     - Parameter instrumentType : FX, CFD, SB
     - Parameter customerOrderId: Unique client order Id (to be generated by the client application)
     - Parameter startPage : starting page
     - Parameter endPage : ending page
     - Returns : A promise which will be performed when API will receive server response.
     */
    public func getWorkingOrderList(instrumentType: String, accNumber: String, customerOrderId: String = "", startPage: Int, endPage: Int) -> Promise {
        
        var data: [String:Any] = ["MTI": 1003,
                                  "accountNumber": accNumber,
                                  "instrumentType": instrumentType]
        
        if customerOrderId != "" {
            data["customerOrderId"] = customerOrderId
        }
        if startPage > 0 && endPage > 0 && endPage > startPage {
            data["startPage"] = startPage
            data["endPage"] = endPage
        }
    
        return super.request(data: data)
    }
    
    /**
    Order list request sent to Trade Server.
     
     # Usage Example: #
     ```
     trade.getCOBOrderList(instrumentType: "FX", accNumber: "123456789").then(success: {resp in
        print(resp) // print order list
     }, failure: {reason, resp in
        print(reason)
     })
     ```
     - Parameter accNumber : Client account number
     - Parameter instrumentType : FX, CFD, SB
     - Returns : A promise which will be performed when API will receive server response.
     */
    public func getCOBOrderList(instrumentType: String, accNumber: String) -> Promise {
        return super.request(data: ["MTI": 1029,
                                    "accountNumber": accNumber,
                                    "noPagination": 1,
                                    "instrumentType": instrumentType])
        
        
    }

    /**
     Ticket list retail request sent to Trade Server.
     
     # Usage Example: #
     ```
     trade.getTicketListRetail(accNumber: "123456789", instrumentType: "FX")
     
     trade.getTicketListRetail(accNumber: "123456789", instrumentType: "FX", status: "OPE")
     
     trade.getTicketListRetail(accNumber: "123456789", instrumentType: "FX", customerOrderId: "111")
     
     trade.getTicketListRetail(accNumber: "123456789", instrumentType: "FX", status: "OPE", customerOrderId: "111")
     
     ```
     The response is received in TicketListRetailUpdate event that you can implement.
     ```
     func TicketListRetailUpdate(data: DATA) {
        print(data)
     }
     ```
     - Parameter accNumber: Client account number
     - Parameter instrumentType: FX, CFD, SB
     - Parameter status: Retail status of the requested tickets. OPE: retrieve opened tickets. / CLO: retrieve closed tickets
     - Parameter customerOrderId: Unique client order Id (to be generated by the client application)
     */
    public func getTicketListRetail (accNumber: String, instrumentType: String, status: String = "", customerOrderId: String = "") {
        var data: [String:Any] = ["MTI": 1011,
                                  "accountNumber": accNumber,
                                  "instrumentType": instrumentType,
                                  "startPage": 1,
                                  "endPage": 1]
        
        if customerOrderId != "" {
            data["customerOrderId"] = customerOrderId
        }
        if status != "" {
            data["status"] = status
        }
    
        super.send(data: data)
    }

    /**
     Ticket list retail request sent to Trade Server.
     
     # Usage Example: #
     ```
     trade.getTicketListRetail(accNumber: "123456789", instrumentType: "FX").then(success: {resp in
        print(resp) // print ticket list
     }, failure: {reason, resp in
        print(reason)
     })
     
     trade.getTicketListRetail(accNumber: "123456789", instrumentType: "FX", status: "OPE").then(success: {resp in
        print(resp) // print ticket list
     }, failure: {reason, resp in
        print(reason)
     })
     
     trade.getTicketListRetail(accNumber: "123456789", instrumentType: "FX", customerOrderId: "111").then(success: {resp in
        print(resp) // print ticket list
     }, failure: {reason, resp in
        print(reason)
     })
     
     trade.getTicketListRetail(accNumber: "123456789", instrumentType: "FX", status: "OPE", customerOrderId: "111").then(success: {resp in
        print(resp) // print ticket list
     }, failure: {reason, resp in
        print(reason)
     })
     
     ```
     - Parameter accNumber: Client account number
     - Parameter instrumentType: FX, CFD, SB
     - Parameter status: Retail status of the requested tickets. OPE: retrieve opened tickets. / CLO: retrieve closed tickets
     - Parameter customerOrderId: Unique client order Id (to be generated by the client application)
     - Returns : A promise which will be performed when API will receive server response.
    */
    public func getTicketListRetailReq (accNumber: String, instrumentType: String, status: String = "", customerOrderId: String = "") -> Promise {
        var data: [String:Any] = ["MTI": 1011,
                                  "accountNumber": accNumber,
                                  "instrumentType": instrumentType,
                                  "startPage": 1,
                                  "endPage": 1]
        
        if customerOrderId != "" {
            data["customerOrderId"] = customerOrderId
        }
        if status != "" {
            data["status"] = status
        }
    
        return super.request(data: data)
    }

    /**
     Ticket list request sent to Trade Server.
     
     # Usage Example: #
     ```
     trade.getTicketList(accNumber: "123456789", instrumentType: "FX").then(success: {resp in
        print(resp) // print ticket list
     }, failure: {reason, resp in
        print(reason)
     })
     ```
     - Parameter accNumber: Client account number
     - Parameter instrumentType: FX, CFD, SB
     - Returns : A promise which will be performed when API will receive server response.
    */
    public func getTicketList(accNumber: String, instrumentType: String) -> Promise {
        return super.request(data: ["MTI": 1004,
                                    "accountNumber": accNumber,
                                    "instrumentType": instrumentType])
    }

    /**
     Change account request sent to Trade Server.
     
     # Usage Example: #
     ```
     trade.changeAccountReq(accNumber: "123456789", userId: 10, dosId: 1).then(success: {resp in
        print(resp) // print server response
     }, failure: {reason, resp in
        print(reason)
     })
     ```
     - Parameter accNumber: Client account number
     - Parameter userId: user ID
     - Parameter dosId: Dossier ID
     - Returns : A promise which will be performed when API will receive server response.
    */
    public func changeAccount(accNumber: String, userId: Int, dosId: CLongLong) -> Promise {
        return super.request(data: ["MTI": 1053,
                                    "accountNumber": accNumber,
                                    "userId": userId,
                                    "dosId": dosId])
    }

    /**
     Strategy list request sent to Trade Server.
     
     # Usage Example: #
     ```
     trade.getStrategyList().then(success: {resp in
        print(resp) // print strategy list
     }, failure: {reason, resp in
        print(reason)
     })
     ```
     - Returns : A promise which will be performed when API will receive server response.
    */
    public func getStrategyList () -> Promise {
        return super.request(data: ["MTI": 1048])
    }

    /**
     Modify order request sent to Trade Server.
     
     # Usage Example: #
     ```
     trade.modifyOrder(order: order, instrumentType: "FX").then(success: {resp in
        print(resp) // server response
     }, failure: {reason, resp in
        print(reason)
     })
     ```
     - Parameter instrumentType: Instrument type
     - Parameter order: data as [String:Any] which contains all the necessary fields for modifying an order strategy.
     - Returns : A promise which will be performed when API will receive server response.
    */
    public func modifyOrder (order: DATA, instrumentType: String) -> Promise {
        var data = order
        data["MTI"] = ""
        if instrumentType == "FX" {
            data["MTI"] = 2008
        }
        else if instrumentType == "CFD" {
            data["MTI"] = 2308
        }
        else if instrumentType == "SB" {
            data["MTI"] = 2508
        }
        return super.request(data: data)
    }

    /**
     Place order strategy request sent to Trade Server.
     
     # Usage Example: #
     ```
     trade.placeOrderStrategy(order: order, instrumentType: "FX").then(success: {resp in
        print(resp) // server response
     }, failure: {reason, resp in
        print(reason)
     })
     ```
     - Parameter instrumentType: Instrument type
     - Parameter order: data as [String:Any] which contains all the necessary fields for placing an order strategy.
     - Returns : A promise which will be performed when API will receive server response.
    */
    public func placeOrderStrategy (order: DATA, instrumentType: String) -> Promise {
        var data = order
        data["MTI"] = ""
        if instrumentType == "FX" {
            data["MTI"] = 2003
        }
        else if instrumentType == "CFD" {
            data["MTI"] = 2303
        }
        else if instrumentType == "SB" {
            data["MTI"] = 2503
        }
        return super.request(data: data)
    }

    /**
     Place order request sent to Trade Server.
     
     # Usage Example: #
     ```
     trade.placeOrder (order: order, instrumentType: "FX").then(success: {resp in
        print(resp) // server response
     }, failure: {reason, resp in
        print(reason)
     })
     ```
     - Parameter instrumentType: Instrument type
     - Parameter order: data as [String:Any] which contains all the necessary fields for placing an order.
     - Returns : A promise which will be performed when API will receive server response.
    */
    public func placeOrder (order: DATA, instrumentType: String) -> Promise {
        var data = order
        data["MTI"] = ""
        if instrumentType == "FX" {
            data["MTI"] = 2000
        }
        else if instrumentType == "CFD" {
            data["MTI"] = 2300
        }
        else if instrumentType == "SB" {
            data["MTI"] = 2500
        }
        return super.request(data: data)
    }

    /**
     Cancel order request sent to Trade Server.
     
     # Usage Example: #
     ```
     trade.cancelOrder(accNumber: "123456789", orderId: 1, instrumentType: "FX", instrumentId: 20, retailSLTP: 0).then(success: {resp in
        print(resp) // server response
     }, failure: {reason, resp in
        print(reason)
     })
     
     trade.cancelOrder(accNumber: "123456789", orderId: 1, instrumentType: "FX", instrumentId: 20, cancelReason: "reason", retailSLTP: 0).then(success: {resp in
        print(resp) // server response
     }, failure: {reason, resp in
        print(reason)
     })
     
     trade.cancelOrder(accNumber: "123456789", orderId: 1, instrumentType: "FX", instrumentId: 20, retailSLTP: 0, customerOrderId: "123").then(success: {resp in
        print(resp) // server response
     }, failure: {reason, resp in
        print(reason)
     })
     
     trade.cancelOrder(accNumber: "123456789", orderId: 1, instrumentType: "FX", instrumentId: 20, cancelReason: "reason", retailSLTP: 0, customerOrderId: "123").then(success: {resp in
        print(resp) // server response
     }, failure: {reason, resp in
        print(reason)
     })
     
     ```
     - Parameter accNumber: Client account number
     - Parameter orderId: Unique internal Orex Order Id
     - Parameter instrumentType: FX, CFD, SB
     - Parameter instrumentId: InstrumentID from the Instrument List response
     - Parameter cancelReason: Cancel reason label
     - Parameter retailSLTP: retailSLTP 0 for standard clients
     - Parameter customerOrderId: Unique client order Id (to be generated by the client application)
     - Returns : A promise which will be performed when API will receive server response.
    */
    public func cancelOrder (accNumber: String, orderId: Int, instrumentType: String, instrumentId: Int, cancelReason: String = "", retailSLTP: Int, customerOrderId: String = "") -> Promise {
        var mti = 0
        if instrumentType == "FX" {
            mti = 2009
        }
        else if instrumentType == "CFD" {
            mti = 2309
        }
        else if instrumentType == "SB" {
            mti = 2509
        }
        
        var data: [String:Any] = ["MTI": mti,
                                  "accountNumber": accNumber,
                                  "orderId": orderId]
        
        if customerOrderId != "" {
            data["customerOrderId"] = customerOrderId
        }
        if instrumentId > 0 {
            data["instrumentId"] = instrumentId
        }
        if retailSLTP >= 0 {
            data["retailSLTP"] = retailSLTP
        }
        if cancelReason != "" {
            data["cancelReason"] = cancelReason
        }
        
        return super.request(data: data)
        
    }

    public func getContacts() -> Promise {
        return super.request(data: ["MTI": 1054])
    }

}

