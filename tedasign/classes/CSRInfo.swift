//
//  CSRInfo.swift
//  tedasign
//
//  Created by Pawan Pankhao on 31/1/2565 BE.
//

import Foundation

class CSRInfo : NSObject, NSCoding {
    var name: String
    var fileName: String
    var chainStatus: Bool
    var certStatus: Bool
    var date: Int
    var localPath: URL?
    var icloudPath: URL?
    var signatureSign: Data?
    
    init(name: String, fileName: String
    , chainStatus: Bool
    , certStatus: Bool
    , date: Int
    , localPath: URL
    , icloudPath: URL
    , signatureSign: Data){
        self.name = name
        self.fileName = fileName
        self.chainStatus = chainStatus
        self.certStatus = certStatus
        self.date = date
        self.localPath = localPath
        self.icloudPath = icloudPath
        self.signatureSign = signatureSign
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        fileName = aDecoder.decodeObject(forKey: "fileName") as? String ?? ""
        //chainStatus = aDecoder.decodeObject(forKey: "chainStatus") as? Bool ?? false
        chainStatus = aDecoder.decodeBool(forKey: "chainStatus")
        //certStatus = aDecoder.decodeObject(forKey: "certStatus") as? Bool ?? false
        certStatus = aDecoder.decodeBool(forKey: "certStatus")
        //date = aDecoder.decodeObject(forKey: "date") as? Int ?? 0
        date = aDecoder.decodeInteger(forKey: "date")
        localPath = aDecoder.decodeObject(forKey: "localPath") as? URL ?? nil
        icloudPath = aDecoder.decodeObject(forKey: "icloudPath") as? URL ?? nil
        signatureSign = aDecoder.decodeObject(forKey: "signatureSign") as? Data ?? nil
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(fileName, forKey: "fileName")
        aCoder.encode(chainStatus, forKey: "chainStatus")
        aCoder.encode(certStatus, forKey: "certStatus")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(localPath, forKey: "localPath")
        aCoder.encode(icloudPath, forKey: "icloudPath")
        aCoder.encode(signatureSign, forKey: "signatureSign")
    }
    
    func mediumDateString() -> String {
        let myDate = Date(timeIntervalSince1970: TimeInterval(date))
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        return formatter.string(from: myDate)
    }
    
    func certStatusString() -> String {
        if certStatus {
            return "Success"
        }
        return "Waiting"
    }
    
    func chainStatusString() -> String {
        if chainStatus {
            return "Success"
        }
        return "Waiting"
    }
    
    
    //TestDate
//        let epocTime = TimeInterval(runNumber)
//        let myDate = Date(timeIntervalSince1970: epocTime)
//        print("Converted Time \(myDate)")
//        let formatter = DateFormatter()
//        formatter.timeStyle = .medium
//        formatter.dateStyle = .medium
//        print(formatter.string(from: myDate))
}
