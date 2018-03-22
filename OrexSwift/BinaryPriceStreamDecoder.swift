extension Character {
    var asciiValue: Int {
        get {
            let s = String(self).unicodeScalars
            return Int(s[s.startIndex].value)
        }
    }
}

// band side
public let ASK: Int = 1;
public let BID: Int = 2;

// FX streamTypes
public let ST_FX_B0: Int       = 1;   // best
public let ST_FX_sA: Int       = 10;  // aggregated for an amount
public let ST_FX_sF: Int       = 20;  // best for an amount
public let ST_FX_A: Int        = 30;  // aggregated by rate
public let ST_FX_FP: Int       = 40;  // best by size
public let ST_FX_MLP: Int      = 50;  // multi LP view
public let ST_FX_F: Int        = 51;  // full price stream (all bands)

// FX streamTypletes: Int (counter ccy trading)
public let ST_FX_FLIP_B0: Int  = 6;   // best
public let ST_FX_FLIP_sA: Int  = 15;  // aggregated for an amount
public let ST_FX_FLIP_sF: Int  = 25;  // best for an amount
public let ST_FX_FLIP_A: Int   = 35;  // aggregated by rate
public let ST_FX_FLIP_FP: Int  = 45;  // best by size
public let ST_FX_FLIP_MLP: Int = 55;  // multi LP view
public let ST_FX_FLIP_F: Int   = 56;  // full price stream (all bands)

// CFD streamTypes
public let ST_CFD_TOB: Int     = 80;  //let top: Int of the book
public let ST_CFD_FULL: Int    = 90;  // full price stream

private class FXBand {
    var bidBankId: Int64!
    var bidTradable: Int!
    var bidSize: Int64!
    var bidRate: String!
    var bidVwap: String!
    var bidValueDate: String!
    
    var askBankId: Int64!
    var askTradable: Int!
    var askSize: Int64!
    var askRate: String!
    var askVwap: String!
    var askValueDate: String!
    
    
    
    init() {
        self.bidBankId = -1
        self.bidTradable = 0
        self.bidSize = 0
        self.bidRate = ""
        self.bidVwap = ""
        self.bidValueDate = ""
        
        self.askBankId = -1
        self.askTradable = 0
        self.askSize = 0
        self.askRate = ""
        self.askVwap = ""
        self.askValueDate = ""
        
    }
    
    public func getDictionary() -> [String:Any]{
        let data: [String:Any] = ["bidBankId": self.bidBankId,
                                  "bidTradable": self.bidTradable,
                                  "bidValueDate": self.bidValueDate,
                                  "bidRate": self.bidRate,
                                  "bidSize": self.bidSize,
                                  "bidVwap": self.bidVwap,
                                  "askBankId": self.askBankId,
                                  "askTradable": self.askTradable,
                                  "askValueDate": self.askValueDate,
                                  "askRate": self.askRate,
                                  "askSize": self.askSize,
                                  "askVwap": self.askVwap]
        
        return data
    }

}

private class CFDBand {
    var bidTradable: Int!
    var bidRate: String!
    var bidSize: Int64!
    
    var askTradable: Int!
    var askRate: String!
    var askSize: Int64!
    
    init() {
        self.bidTradable = 0
        self.bidRate = ""
        self.bidSize = 0
        self.askTradable = 0
        self.bidRate = ""
        self.bidSize = 0
        
    }
    
    public func getDictionary() -> [String:Any] {
        let data: [String:Any] = ["bidTradable": self.bidTradable,
                                  "bidRate": self.bidRate,
                                  "bidSize": self.bidSize,
                                  "askTradable": self.askTradable,
                                  "askRate": self.askRate,
                                  "askSize": self.askSize]
        
        return data
    }
}

private class Instrument {
    var id: Int!         // instrument id
    var streamType: Int!   // stream type
    
    init() {
        self.id = -1
        self.streamType = 0
    }
    
    func getDictionary() -> [String:Any]{return [:]}

}

private class FXInstrument: Instrument {
    var size: Int64!      // requested size (sA and sF)
    var bands: [FXBand]!  // bands

    override init() {
        super.init()
        self.size = 0
        self.bands = []
    }
    
    public func bandCount() -> Int {
        return self.bands.count
    }
    
    public func band(idx: Int) -> FXBand {
        return self.bands[idx]
    }
    
    public func addBand(band: FXBand) {
        self.bands.append(band)
    }
    
    public override func getDictionary() -> [String:Any]{
        var bandList: [[String:Any]] = []
        for band in self.bands {
            bandList.append(band.getDictionary())
        }
        
        let data: [String:Any] = ["instrumentId": self.id,
                                  "streamType": self.streamType,
                                  "size": self.size,
                                  "bandList": bandList]
        
        return data
    }
    
}

private class CFDInstrument: Instrument {
    var open: Double!          // today's opening price
    var high: Double!          // today's highest rate
    var low: Double!           // today's lowest rate
    var close: Double!         // yesterday's closing price
    var bands: [CFDBand]!      // bands
    
    override init() {
        super.init()
        self.open = 0
        self.high = 0
        self.low = 0
        self.close = 0
        self.bands = []
    }
    
    public func bandCount() -> Int {
        return self.bands.count
    }
    
    public func band(idx: Int) -> CFDBand {
        return self.bands[idx]
    }
    
    public func addBand(band: CFDBand) {
        self.bands.append(band)
    }
    
    public override func getDictionary() -> [String:Any] {
        var bandList: [[String:Any]] = []
        for band in self.bands {
            bandList.append(band.getDictionary())
        }
        
        let data: [String:Any] = ["instrumentId": self.id,
                                  "streamType": self.streamType,
                                  "open": self.open,
                                  "close": self.close,
                                  "high": self.high,
                                  "low": self.low,
                                  "bandList": bandList]
        
        return data
    }
}

// class representing the decoded market data
public class MarketData {
    private var data: [Instrument]!
    
    init() {
        self.data = []
    }
    
    private func add(ins: Instrument) {
        self.data.append(ins)
    }
    
    public func getData() -> [[String:Any]] {
        var instrumentList: [[String:Any]] = []
        for instrument in data {
            instrumentList.append(instrument.getDictionary())
        }
        
        return instrumentList
    }
    
    private func parseHexBinaryInt(buffer: [Character], offset: Int, byteCount: Int) -> Int64 {
        var value: Int64 = 0
        // integers are in intel byte ordering (little endian)
        
        for i in (1...((byteCount >> 1))).reversed(){
            value <<= 4
            var nibble = buffer[offset + (i << 1) - 2]
            if nibble.asciiValue >= Character("0").asciiValue && nibble.asciiValue <= Character("9").asciiValue {
                value += Int64(nibble.asciiValue) - Int64(Character("0").asciiValue)
            }
            else if nibble.asciiValue >= Character("A").asciiValue && nibble.asciiValue <= Character("F").asciiValue {
                value += Int64(nibble.asciiValue) - Int64(Character("A").asciiValue) + 10
            }
            else if nibble.asciiValue >= Character("a").asciiValue && nibble.asciiValue <= Character("f").asciiValue {
                value += Int64(nibble.asciiValue) - Int64(Character("a").asciiValue) + 10
            }
            value <<= 4
            nibble = buffer[offset + (i << 1) - 1]
            if nibble.asciiValue >= Character("0").asciiValue && nibble.asciiValue <= Character("9").asciiValue {
                value += Int64(nibble.asciiValue) - Int64(Character("0").asciiValue)
            }
            else if nibble.asciiValue >= Character("A").asciiValue && nibble.asciiValue <= Character("F").asciiValue {
                value += Int64(nibble.asciiValue) - Int64(Character("A").asciiValue) + 10
            }
            else if nibble.asciiValue >= Character("a").asciiValue && nibble.asciiValue <= Character("f").asciiValue {
                value += Int64(nibble.asciiValue) - Int64(Character("a").asciiValue) + 10
            }
        }
        
        return value
    }
    
    // get 16 hexadecimal characters from buffer and convert them into double value
    private func parseHexBinaryDouble(buffer: [Character], offset: Int) -> Double{
        let value: Int64 = self.parseHexBinaryInt(buffer: buffer, offset: offset, byteCount: 16)
        return Double(bitPattern: UInt64(value))
    }
    
    // decode an FX instrument
    private func decodeFX(insid: Int, streamType: Int, buffer: [Character], offset: Int) -> Int {
        var currentStreamType = streamType
        var currentOffset = offset
        
        // create the instrument
        let ins = FXInstrument()
        ins.id = insid
        ins.streamType = streamType
        
        // convert counter currency streamTypes to base currency streamTypes
        // to simplify later processing
        
        switch currentStreamType
        {
        case ST_FX_FLIP_B0, ST_FX_FLIP_sA, ST_FX_FLIP_sF, ST_FX_FLIP_A,ST_FX_FLIP_FP, ST_FX_FLIP_MLP, ST_FX_FLIP_F:
            currentStreamType -= 5
            break
        default: break
        }
        
        // present only for these stream types
        if (currentStreamType == ST_FX_sA)||(currentStreamType == ST_FX_sF) {
            let size: Int64 = parseHexBinaryInt(buffer: buffer, offset: currentOffset, byteCount: 16)
            currentOffset += 16
            ins.size = size
            
        }
        
        // get the band count
        let bandCount = Int(parseHexBinaryInt(buffer: buffer, offset: currentOffset, byteCount: 2))
        currentOffset += 2
        
        var bidQueue: [FXBand] = []
        var askQueue: [FXBand] = []
        
        // parse the bands
        for _ in 0..<bandCount {
            var bankId: Int64 = 0
            
            if currentStreamType == ST_FX_MLP {
                bankId = parseHexBinaryInt(buffer: buffer, offset: currentOffset, byteCount: 2)
                currentOffset += 2
            }
            
            var isBid = false
            var isTradable = false
            var valueDateStr = ""
            
            // then comes the flags
            // format STIVVVVV (side tradable indicative valueDate)
            let flags = parseHexBinaryInt(buffer: buffer, offset: currentOffset, byteCount: 2)
            currentOffset += 2
            if (flags & 0x80) != 0 {
                isBid = true
            }
            else {
                isBid = false
            }
            if (flags & 0x40) != 0 {
                isTradable = true
            }
            if (flags & 0x20) != 0 {
                isTradable = false
            }
            
            let valueDate = Int(flags & 0x1f)
            
            // was not present before R071_03
            if valueDate != 0 {
                // get current date
                let cal = Calendar.current
                let component = cal.dateComponents([.day,.month,.year], from: Date())
                var year = component.year!
                var mouth = component.month! + 1
                let day = component.day!
                
                // the valueDate holds only the day, if day is smaller than current day
                // the we cross the month boundary and need to handle i
                if valueDate < day {
                    mouth += 1
                    if mouth > 12 {
                        mouth = 1
                        year += 1
                    }
                }
                
                // format the full value date
                valueDateStr = String(format: "%04d%02d%02d", year, mouth, valueDate)
            }
            
            // then comes the rate
            let rate: Double = parseHexBinaryDouble(buffer: buffer, offset: currentOffset)
            currentOffset += 16
            
            // size is not present for B0
            var size: Int64 = 0
            if currentStreamType != ST_FX_B0 {
                size = parseHexBinaryInt(buffer: buffer, offset: currentOffset, byteCount: 16)
                currentOffset += 16
            }
            
            // vwap is present only in sA
            var vwap: Double = 0
            if currentStreamType == ST_FX_sA {
                vwap = parseHexBinaryDouble(buffer: buffer, offset: currentOffset)
                currentOffset += 16
            }
            
            if isBid {
                var band = FXBand()
                if askQueue.count > 0 {
                    band = askQueue.remove(at: 0)
                }
                else {
                    bidQueue.append(band)
                    ins.addBand(band: band)
                }
                
                band.bidBankId = bankId
                band.bidTradable = isTradable ? 1 : 0
                band.bidSize = size
                band.bidRate = String(rate)
                band.bidVwap = String(vwap)
                band.bidValueDate = valueDateStr
            }
            else {
                var band = FXBand()
                if bidQueue.count > 0 {
                    band = bidQueue.remove(at: 0)
                }
                else {
                    askQueue.append(band)
                    ins.addBand(band: band)
                }
                band.askBankId = bankId
                band.askTradable = isTradable ? 1 : 0
                band.askSize = size
                band.askRate = String(rate)
                band.askVwap = String(vwap)
                band.askValueDate = valueDateStr
                
            }
        }
        // add the instrument to decoded md
        self.add(ins: ins)
        return currentOffset
    }
    
    // decode a CFD instrument
    private func decodeCFD(insid: Int, streamType: Int, buffer: [Character], offset: Int) -> Int{
        var currentOffset = offset
        
        // create the instrument
        let ins = CFDInstrument()
        ins.id = insid
        ins.streamType = streamType
        
        // get the band count
        let bandCount = parseHexBinaryInt(buffer: buffer, offset: currentOffset, byteCount: 2)
        currentOffset += 2
        
        // get instrument informations
        let close = parseHexBinaryDouble(buffer: buffer, offset: currentOffset)
        currentOffset += 16
        let open = parseHexBinaryDouble(buffer: buffer, offset: currentOffset)
        currentOffset += 16
        let low = parseHexBinaryDouble(buffer: buffer, offset: currentOffset)
        currentOffset += 16
        let high = parseHexBinaryDouble(buffer: buffer, offset: currentOffset)
        currentOffset += 16
        ins.close = close
        ins.open = open
        ins.low = low
        ins.high = high
        
        var bidQueue: [CFDBand] = []
        var askQueue: [CFDBand] = []
        
        // parse the bands
        for _ in 0..<bandCount {
            var isBid = false
            var isTradable = false
    
            // flags
            // format STUUUUUU (side tradable unused)
            let flags = parseHexBinaryInt(buffer: buffer, offset: currentOffset, byteCount: 2)
            currentOffset += 2
            
            if (flags & 0x80) != 0 {
                isBid = true
            }
            else {
                isBid = false
            }
            if (flags & 0x40) != 0 {
                isTradable = true
            }
            
            // then comes the rate
            let rate = parseHexBinaryDouble(buffer: buffer, offset: currentOffset)
            currentOffset += 16
            
            // then comes the size
            let size = parseHexBinaryInt(buffer: buffer, offset: currentOffset, byteCount: 16)
            currentOffset += 16
            
            if isBid {
                var band = CFDBand()
                if askQueue.count > 0 {
                    band = askQueue.remove(at: 0)
                }
                else {
                    bidQueue.append(band)
                    ins.addBand(band: band)
                }
                band.bidTradable = isTradable ? 1 : 0
                band.bidRate = String(rate)
                band.bidSize = size
            }
            else {
                var band = CFDBand()
                if bidQueue.count > 0 {
                    band = bidQueue.remove(at: 0)
                }
                else {
                    askQueue.append(band)
                    ins.addBand(band: band)
                }
                band.askTradable = isTradable ? 1 : 0
                band.askRate = String(rate)
                band.askSize = size
            }
        }
        self.add(ins: ins)
        return currentOffset
    }
    
    // decode a binary stream
    public func decode(buffer: [Character]) -> [[String:Any]]{
        var offset = 0
        let max = buffer.count
        
        // parse the whole buffer
        while offset < max {
            // get the instrument id
            var insid = Int(parseHexBinaryInt(buffer: buffer, offset: offset, byteCount: 2))
            offset += 2
            
            // if insid is greater than 0x7f then first byte indicates the number of bytes encoding the insid
            if (insid & 0x80) != 0 {
                let count = Int((insid & 0x7f) << 1)
                insid = Int(parseHexBinaryInt(buffer: buffer, offset: offset, byteCount: count))
                offset += count
            }
            // get the streamType
            let streamType = Int(parseHexBinaryInt(buffer: buffer, offset: offset, byteCount: 2))
            offset += 2
            
            // then found the asset
            switch streamType {
                // FX asset
                case ST_FX_B0, ST_FX_sA, ST_FX_sF, ST_FX_A, ST_FX_FP, ST_FX_MLP, ST_FX_F, ST_FX_FLIP_B0, ST_FX_FLIP_sA, ST_FX_FLIP_sF, ST_FX_FLIP_A, ST_FX_FLIP_FP, ST_FX_FLIP_MLP, ST_FX_FLIP_F:
                    
                    offset = decodeFX(insid: insid, streamType: streamType, buffer: buffer, offset: offset)
                    break
                // CFD asset
                case ST_CFD_TOB, ST_CFD_FULL:
                    
                    offset = decodeCFD(insid: insid, streamType: streamType, buffer: buffer, offset: offset)
                    break
                default : break
            }
        }
        return self.getData()
    }
}



    
    








