//
//  CdrHelpers.swift
//  RaspberryPiClient
//
//  CDR 形式の共通ヘルパー（複数サービスで共用）
//  Ref: https://www.omg.org/spec/DDS-XTypes/
//

import Foundation

/// CDR 形式の共通ヘルパー（複数サービスで共用）
enum CdrHelpers {
    /// CDR カプセル化ヘッダー（4 バイト）
    /// - バイト 0-1: 0x00 0x01 → CDR_LE (Little Endian) を表す（0x00 0x00 の場合は CDR_BE）
    /// - ROS 2 は通常 CDR_LE を使用
    /// - デコード時はこの 4 バイトをスキップしてペイロードを読み込む
    static let encapsulationHeader: [UInt8] = [0x00, 0x01, 0x00, 0x00]

    /// CDR string をエンコード（4byte length + UTF-8 + NUL）
    /// - Parameter value: エンコードする文字列（nil の場合は空文字として扱う）
    /// - Returns: CDR 形式の string データ
    static func encodeCdrString(_ value: String?) -> Data {
        let nameBytes = (value ?? "").data(using: .utf8) ?? Data()
        let length = UInt32(nameBytes.count + 1)
        var data = Data()
        data.append(contentsOf: withUnsafeBytes(of: length.littleEndian) { Array($0) })
        data.append(nameBytes)
        data.append(0)
        return data
    }

    /// CDR string をデコード
    /// - Parameters:
    ///   - data: CDR データ
    ///   - offset: string の開始位置（4byte length の先頭）
    /// - Returns: デコードされた文字列。範囲外または不正なデータの場合は nil
    static func decodeCdrString(from data: Data, at offset: Int) -> String? {
        guard data.count >= offset + 4 else { return nil }
        let lengthBytes = data.subdata(in: offset ..< (offset + 4))
        let length = lengthBytes.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian }
        guard data.count >= offset + 4 + Int(length), length > 0 else { return nil }
        let stringData = data.subdata(in: (offset + 4) ..< (offset + 4 + Int(length) - 1))
        return String(data: stringData, encoding: .utf8)
    }
}
