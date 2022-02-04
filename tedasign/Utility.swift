//
//  Utility.swift
//  tedamobilesigning
//
//  Created by Prawit Phiwhom on 8/3/2564 BE.
//

import Foundation
import LocalAuthentication
import UIKit


//Biometric Authentication
public func DeviceAuthentication()->Bool {
    
    let contet = LAContext()
    let reason = "กรุณายืนยันตัวตนของท่าน"
    var authError: NSError?
    var Re = "false"
    
    if #available(iOS 8.0, macOS 10.12.1, *) {
        
        if contet.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            contet.localizedCancelTitle = "Cancel"
            contet.localizedFallbackTitle = ""
            contet.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                success, evaluateError in DispatchQueue.main.async {
                    if success {
                        print("success")
                        Re = "true"
                        //print(Re)
                    }
                    else {
                        // User did not authenticate successfully, look at error and take appropriate action
                        print(evaluateError!.localizedDescription)
                        Re = "false"
                    }
                }
            }
        }
        else {
        // Could not evaluate policy; look at authError and present an appropriate message to user
        print("Sorry!!.. Could not evaluate policy.\(authError!.localizedDescription)")
            Re = "false"
            return NSString(string: Re).boolValue
        }
    }
    else {
        print("This feature is not supported.")
        Re = "false"
        return NSString(string: Re).boolValue
    }
    
    return NSString(string: Re).boolValue
}

/// Date
public func CurrentTimeStamp(dateFormatter: String)-> String{
    let date = Date()
    let df = DateFormatter()
    df.dateFormat = dateFormatter
    return df.string(from: date)
}

//public func showAlert(){
//    let alert = UIAlertController(title: "Success", message: "Successfully Digital Signature Singed", preferredStyle: .alert)
//    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//    present(alert, animated: true, completion: nil)
//}

// Key Chain  ############################################


public func SaveNewKeyfile2Keychain(KeyData: NSData, PasswordFile: String, tagKeyName: String,timestamp:String){
    
   
//    let keychain = Keychain()
//    do {
//        try AppDelegate.keychains.remove(tagKeyName)
//        //keychain[data: tagKeyName] = KeyData as Data
//    } catch let error {
//        print("error: \(error)")
//    }
    
    DispatchQueue.global().async {
        do {
            try AppDelegate.keychains
                //.accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
//                .accessibility(.alwaysThisDeviceOnly, authenticationPolicy: .userPresence)
//                .authenticationPrompt(MSAuthenReason)
//                .comment(PasswordFile)
                .label(timestamp)
                .set(KeyData as Data, key: tagKeyName)
        } catch let error {
            print("error: \(error)")
        }
        do {
            try AppDelegate.keychains
                //.accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
//                .accessibility(.alwaysThisDeviceOnly, authenticationPolicy: .userPresence)
//                .authenticationPrompt(MSAuthenReason)
//                .comment(PasswordFile)
//                .label(PasswordFile)
                .set(PasswordFile, key: tagKeyName+"_password")
        } catch let error {
            print("error: \(error)")
        }
    }
    
    
}

public func getDataKey(tagKeyName: String)->NSData{
    
    //let keychain = Keychain()
    let reData = AppDelegate.keychains[data: tagKeyName]
    
    
    return reData! as NSData
    
}

public func getPasswordFile(tagKeyName: String)->String{
    
//    var pass:String = ""
//    if let attributes = AppDelegate.keychains[attributes: tagKeyName+"_password"] {
//        //print(attributes.label)
//        pass = attributes.label!
//    }
    
    guard let pass = AppDelegate.keychains[string: tagKeyName+"_password"] else { return "" }
//    do {
//        let attributes = try AppDelegate.keychains.get(tagKeyName) { $0 }
//        print(attributes?.comment)
//        print(attributes?.label)
//        pass = attributes?.label ?? ""
//    } catch let error {
//        print("error: \(error)")
//    }
    
    return pass
    
}

public func getDate(tagKeyName: String)->String{
    
//    var pass:String = ""
//    if let attributes = AppDelegate.keychains[attributes: tagKeyName+"_password"] {
//        //print(attributes.label)
//        pass = attributes.label!
//    }
    
//    guard let pass = AppDelegate.keychains[string: tagKeyName+"_password"] else { return "" }
    do {
        let attributes = try AppDelegate.keychains.get(tagKeyName) { $0 }
        print(attributes?.comment)
        print(attributes?.label)
        return attributes?.label ?? ""
    } catch let error {
        print("error: \(error)")
    }
    
    return ""
    
}

public func SelectAllKey() -> [String]{
    //let keychain = Keychain()
    var data = [String]()
    
    let keys = AppDelegate.keychains.allKeys()
    
    for value in keys{
        if(!value.contains("_password")){
            data.append(value)
        }
    }
    
    return data
}

public func CheckKeyNameDuplicate(tagKeyName: String)-> Bool{
    
    let keys = AppDelegate.keychains.allKeys()
    for key in keys {
        if key == tagKeyName {
            return true
        }
    }
    return false
}

public func RemoveAllKey(){
    
    let keys = AppDelegate.keychains.allKeys()
    for key in keys {
        do {
            try AppDelegate.keychains.remove(key)
        } catch let error {
            print("error: \(error)")
        }
    }
}

public func deleteKey(name:String){
    
    
    do {
              try AppDelegate.keychains.remove(name)
          } catch let error {
              print("error: \(error)")
          }
//    for key in keys {
//        do {
//            try AppDelegate.keychains.remove(key)
//        } catch let error {
//            print("error: \(error)")
//        }
//    }
}


