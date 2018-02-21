import Foundation

public extension Data {

    public init?(hexEncoded hexData: Data) {

        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeDigit(_ digit: UInt8) -> UInt8? {

            switch digit {

            case 0x30 ... 0x39:
                return UInt8(digit - 0x30)

            case 0x41 ... 0x46:
                return UInt8(digit - 0x41 + 10)

            case 0x61 ... 0x66:
                return UInt8(digit - 0x61 + 10)

            default:
                return nil

            }

        }

        let inCount = hexData.count

        guard (inCount & 1) == 0    // must be even
            else { return nil }

        self.init(capacity: inCount >> 1)

        var index = 0

        while index < inCount {

            guard let digitHi = decodeDigit(hexData[index]),
                let digitLo = decodeDigit(hexData[index + 1])
                else { return nil }

            append(UInt8((digitHi << 4) | digitLo))

            index += 2

        }

    }

    public init?(hexEncoded hexString: String) {

        guard let hexData: Data = hexString.data(using: .utf8)
            else { return nil }

        self.init(hexEncoded: hexData)

    }

    public func hexEncodedData() -> Data {

        return hexEncodedString().data(using: .utf8) ?? Data()

    }

    public func hexEncodedString() -> String {

        return map { String(format: "%02hhx", $0) }.joined()

    }

}
