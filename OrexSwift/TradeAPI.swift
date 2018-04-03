import UIKit
import CryptoSwift

public protocol TradeDelegate: class {
    func tradeConnected()
    func tradeDisconnected()
    func TopAccountSummary(data: DATA) // 6000
    func AccountSummaryRetailUpdate(data: DATA) // 4005
    func AccountSummaryUpdate(data: DATA) // 4000
    func PositionUpdate(data: DATA) // 1005
    func TicketListRetailUpdate(data: DATA) // 1011
//    func TicketListResponse(data: DATA) // 1004
    func OrderUpdate(data: DATA) // 6000
    func AlertMessage(data: DATA) // 1320 1321 4010
}

public class TradeAPI: APIBase {

    public weak var delegate: TradeDelegate?

    public override init() {
        super.init()
    }

    public func connect(endpoint: String) {
        super.connect(name: "TRADE", endpoint: endpoint)
    }

    public func close() {
        super.disconect()
    }

    public func login(login: String, password: String) -> Promise {
        return super.request(data: ["MTI": 1001,
                                    "version": "admin",
                                    "stationTypeName": "Trader",
                                    "login": login,
                                    "password": password.sha256()])
    }

    internal override func onConnect() {
        if(devMode) {
            print("[TRADE] connected: \(self.socket.url)")
        }
        delegate?.tradeConnected()
        super.onConnect()
    }

    internal override func OnClose() {
        if(devMode) {
            print("[TRADE] disconnected")
        }
        delegate?.tradeDisconnected()
        super.OnClose()
    }

    internal override func OnMessage(data : DATA) {
        if data["MTI"] != nil {
            let mti = data["MTI"] as! Int
            switch (mti) {
            case 4012:
                self.delegate?.TopAccountSummary(data: data)
                break
            case 4000:
                self.delegate?.AccountSummaryUpdate(data: data)
                break
            case 4005:
                self.delegate?.AccountSummaryRetailUpdate(data: data)
                break
            case 1005:
                self.delegate?.PositionUpdate(data: data)
                break
//            case 1004:
//                self.delegate?.TicketListResponse(data: data)
//                break
            case 1011:
                self.delegate?.TicketListRetailUpdate(data: data)
                break
            case 1320, 1321, 4010:
                self.delegate?.AlertMessage(data: data)
                break
            case 6000:
                print(6000)
                self.delegate?.OrderUpdate(data: data)
                break
//            case 6001: break
            default:
                break
            }
        }
        else {
            print(data
            )
        }
        super.OnMessage(data: data)
    }

    public func getAccountList () -> Promise {
        return super.request(data: ["MTI": 1031])
    }

    public func getFXList () -> Promise {
        return super.request(data: ["MTI": 1002,
                                    "category": "FX"])
    }

    public func getCFDList (lastCFDUpdate: String = "") -> Promise { // format YYYYMMDDHHMMSS
        var data: DATA = ["MTI": 1202]
        if lastCFDUpdate != "" {
            data["lastCFDUpdate"] = lastCFDUpdate
        }
        return super.request(data: data)
    }

    public func getSBList (lastSBUpdate: String = "") -> Promise { // format YYYYMMDDHHMMSS
        var data: DATA = ["MTI": 1302]
        if lastSBUpdate != "" {
            data["lastSBUpdate"] = lastSBUpdate
        }
        return super.request(data: data)
    }

    public func getAccountSummaryRetail (accNumber: String) {
        super.send(data: ["MTI": 4005, "accountNumber": accNumber])
    }

    public func getAccountSummary (accNumber: String = "", dosId: Int = -1) {
        dosId != -1 ? super.send(data: ["MTI": 4000, "dosId": dosId]) : super.send(data: ["MTI": 4000, "accountNumber": accNumber])
    }

    public func getPositions (accNumber: String, asset: String) {
        self.send(data: ["MTI": 1005,
                                   "accountNumber": accNumber,
                                   "instrumentType": asset])
    }

    public func getPositionsReq (accNumber: String, asset: String) -> Promise {
        return self.request(data: ["MTI": 1005,
                                   "accountNumber": accNumber,
                                   "instrumentType": asset])
    }

    public func requestChartsData (accountNumber: String, insType: String, insId: String, beginDate: String, endDate: String, period: String) -> Promise {
        return self.request(data: ["MTI": 1100,
                                   "instrumentType": insType,
                                   "instrumentId": insId,
                                   "chartStartDateTime": beginDate,
                                   "chartEndDateTime": endDate,
                                   "chartTimeScale": period,
                                   "accountNumber": accountNumber])
    }

    public func getWorkingOrderList (accNumber: String) -> Promise {
        return super.request(data: ["MTI": 1029, // 1003
                                    "accountNumber": accNumber,
                                    "noPagination": 1])
    }

    public func getTicketListRetail (accNumber: String, asset: String) {
        super.send(data: ["MTI": 1011,
                          "accountNumber": accNumber,
                          "noPagination": 1,
                          "instrumentType": asset])
    }

    public func getTicketListRetailReq (accNumber: String, asset: String, status: String = "") -> Promise {
        if status == "" {
            return super.request(data: ["MTI": 1011,
                                        "accountNumber": accNumber,
                                        "noPagination": 1,
                                        "instrumentType": asset])
        }
        else {
            return super.request(data: ["MTI": 1011,
                                        "accountNumber": accNumber,
                                        "noPagination": 1,
                                        "status": status,
                                        "instrumentType": asset])
        }
    }

    public func getTicketList(accNumber: String, asset: String) -> Promise {
        return super.request(data: ["MTI": 1004,
                                    "accountNumber": accNumber,
                                    "instrumentType": asset,
                                    "startPage": 1,
                                    "endPage": 1])
    }

    public func changeAccount(accNumber: String, userId: Int, dosId: Int) {
        super.send(data: ["MTI": 1053,
                          "accountNumber": accNumber,
                          "userId": userId,
                          "dosId": dosId])
    }

    public func getStrategyList () -> Promise {
        return super.request(data: ["MTI": 1048])
    }

    public func modifyOrder (order: DATA, instrumentType: String) -> Promise {
        var msg = order
        msg["MTI"] = ""
        if instrumentType == "FX" {
            msg["MTI"] = 2008
        }
        else if instrumentType == "CFD" {
            msg["MTI"] = 2308
        }
        else if instrumentType == "SB" {
            msg["MTI"] = 2508
        }
        return super.request(data: msg)
    }

    public func placeOrderStrategy (order: DATA, instrumentType: String) -> Promise {
        var msg = order
        msg["MTI"] = ""
        if instrumentType == "FX" {
            msg["MTI"] = 2003
        }
        else if instrumentType == "CFD" {
            msg["MTI"] = 2303
        }
        else if instrumentType == "SB" {
            msg["MTI"] = 2503
        }
        return super.request(data: msg)
    }

    public func placeOrder (order: DATA, instrumentType: String) -> Promise {
        var msg = order
        msg["MTI"] = ""
        if instrumentType == "FX" {
            msg["MTI"] = 2000
        }
        else if instrumentType == "CFD" {
            msg["MTI"] = 2300
        }
        else if instrumentType == "SB" {
            msg["MTI"] = 2500
        }
        return super.request(data: msg)
    }

    public func cancelOrder (accNumber: String, order: DATA, instrumentType: String) -> Promise {
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
        return super.request(data: ["MTI": mti,
                                    "accountNumber": accNumber,
                                    "orderId": order["orderId"] as! Int,
                                    "customerOrderId": order["customerOrderId"] as! String,
                                    "instrumentId": order["instrumentId"] as! Int,
                                    "retailSLTP": order["retailSLTP"] as! Int])
    }

    public func getContacts() -> Promise {
        return super.request(data: ["MTI": 1054])
    }

}

