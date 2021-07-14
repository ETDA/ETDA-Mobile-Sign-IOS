//
//  PKCS12.swift
//  TedaMobile
//
//  Created by Mee on 15/2/2564 BE.
//

import Foundation

/**
 Struct representing values returned by `SecPKCS12Import` from the Security framework.
 
 This is what Cocoa and CocoaTouch can tell you about a PKCS12 file.
 
 */
public class PKCS12 {
    let label:String?
    let keyID:NSData?
    let trust:SecTrust?
    let certChain:[SecCertificate]?
    let identity_:SecIdentity?
    let cert_:SecCertificate?
    
    public init(PKCS12Data:NSData,password:String)
    {
        let importPasswordOption:NSDictionary = [kSecImportExportPassphrase as NSString:password]
        var items : CFArray?
        let secError:OSStatus = SecPKCS12Import(PKCS12Data, importPasswordOption, &items)
        
        guard secError == errSecSuccess else {
            if secError == errSecAuthFailed {
                NSLog("ERROR: SecPKCS12Import returned errSecAuthFailed. Incorrect password?")
            }
            fatalError("SecPKCS12Import returned an error trying to import PKCS12 data")
        }
        
        guard let theItemsCFArray = items else { fatalError()  }
        let theItemsNSArray:NSArray = theItemsCFArray as NSArray
        guard let dictArray = theItemsNSArray as? [[String:AnyObject]] else { fatalError() }
       
        func f<T>(key:CFString) -> T? {
            for d in dictArray {
                if let v = d[key as String] as? T {
                    return v
                }
            }
            return nil
        }
        
        self.label = f(key: kSecImportItemLabel)
        self.keyID = f(key: kSecImportItemKeyID)
        self.trust = f(key: kSecImportItemTrust)
        self.certChain = f(key: kSecImportItemCertChain)
        self.identity_ =  f(key: kSecImportItemIdentity)
//        if SecIdentityCopyPrivateKey(secIdentity, &Cert) == errSecSuccess {
//            return Cert
//        }
        
        self.cert_ = certChain?.first!
        
//        print( "label:" ,self.label);
//        print( "keyID: " ,self.keyID );
//        print( "trust: " ,self.trust!);
//        print( "certChain: " ,self.certChain!);
//        print( "certChain: " ,self.certChain!.first!);
//        print( "identity: " ,self.identity_!)
//        print(certChain(Cert: self.certChain!.first!))
//        print(certChain(Cert: self.certChain![1]))
//        print("3.1: \(convertSecKeyToBase64(self.certChain!.first!))")
//        print("3.2: \(convertSecKeyToBase64(self.certChain![1]))")
//        extractIdentityx(PKCS12Data: PKCS12Data, password: password)
    }
    
    public func getCertChain() -> [String]{
//        print(certChain(Cert: self.certChain!.first!))
//        print(certChain(Cert: self.certChain![1]))
        return [convertSecKeyToBase64Cert(self.certChain!.first!),convertSecKeyToBase64Cert(self.certChain![1])]
    }
    
    public func convertSecKeyToBase64Cert(_ inputKey: SecCertificate)-> String{
        let KeyData = SecCertificateCopyData(inputKey)
        let KeyNSData = NSData(data: KeyData as Data)
        let KeyBase64Str = KeyNSData.base64EncodedString()
        //print(KeyBase64Str)
        return KeyBase64Str
    }
    
   public struct IdentityAndTrust {

        var identityRef:SecIdentity
        var trust:SecTrust
        var certArray:AnyObject
    }
    
   public func extractIdentityx(PKCS12Data:NSData,password:String){
        var identityAndTrust:IdentityAndTrust!
        var securityError:OSStatus = errSecSuccess

        //let path: String = Bundle.main.path(forResource: Name, ofType: "p12")!
        //let PKCS12Data = NSData(contentsOfFile:path)!
        let key : NSString = kSecImportExportPassphrase as NSString
        let options : NSDictionary = [key : password]
        //create variable for holding security information
        //var privateKeyRef: SecKeyRef? = nil

        var items : CFArray?

         securityError = SecPKCS12Import(PKCS12Data, options, &items)

        if securityError == errSecSuccess {
            let certItems:CFArray = items!
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {

                print("dict : \(dict!)")
                print("certEntry : \(certEntry)")
                
                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentity = identityPointer! as! SecIdentity
                print("1: \(identityPointer!)  :::: \(secIdentityRef)")
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"];
                let trustRef:SecTrust = trustPointer as! SecTrust;
                print("2: \(trustPointer!)  :::: \(trustRef)")
                let trustkey = SecTrustCopyKey(trustRef)
                print("2.1 :\(String(describing: trustkey))")
                let trustkeyB64 = convertSecKeyToBase64(trustkey!)
                print("2.2 :\(trustkeyB64)")
                // grab the cert
                let chainPointer:AnyObject? = certEntry["chain"];
                print("3: \(certEntry["chain"]!)  ::::-")
                let certChain_1:SecCertificate = chainPointer![0] as! SecCertificate
                let certChain_2:SecCertificate = chainPointer![1] as! SecCertificate
//                print("3.1: \(convertSecKeyToBase64(certChain_1))")
//                print("3.2: \(convertSecKeyToBase64(certChain_2))")
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray:  chainPointer!);
                
                
                var certRef: SecCertificate?
                SecIdentityCopyCertificate(secIdentityRef, &certRef);
                let certArray:NSMutableArray = NSMutableArray();
                certArray.add(certRef as SecCertificate?);
                print("333 : \(certArray)")
                
                //
//                var cert_ : SecCertificate? = nil
//                //var chain_ : SecCertificate? = nil
//                SecIdentityCopyCertificate(certChain_1, &cert_)
//                let cert_sk:SecKey = xx(SecCert: cert_!)
//                let cert_b64 = convertSecKeyToBase64(cert_sk)
//                print("3.1.1 : \(cert_b64)")
            
                let cfarr:CFArray
            }
        }
    
        print("iden.#########################")
        print("4 : \(identityAndTrust!)")
    print("5: \(identityAndTrust.trust)")
        print("6: \(identityAndTrust.certArray[0]!)")
    print("6: \(identityAndTrust.certArray[1]!)")
        print("#########################")
    
//    let x = convertSecKeyToBase64(identityAndTrust.identityRef as! SecKey)
//    print("CerArray #########")
//    print(x)
    
//        return identityAndTrust;
    }
    public func certChain(Cert: SecCertificate)->String{
    //    let Cert: SecCertificate =  rsa_CertChain_from_data_(d ,withPassword: withPassword)!
        print("Cert : \(Cert)")
        let CertValue : SecKey = xx(SecCert: Cert)
        //print("CertValue : \(CertValue)")
        let CertB64 = convertSecKeyToBase64(CertValue)
        //print("CertValueB64 : \(CertB64)")
        return CertB64
    }
    public func certChain2(Cert: SecCertificate)->String{
    //    let Cert: SecCertificate =  rsa_CertChain_from_data_(d ,withPassword: withPassword)!
        print("Cert : \(Cert)")
        let CertValue : SecKey = yy(SecCert: Cert)
        //print("CertValue : \(CertValue)")
        let CertB64 = convertSecKeyToBase64(CertValue)
        //print("CertValueB64 : \(CertB64)")
        return CertB64
    }
}
//
public func CheckFileImportP12(PKCS12Data:NSData,password:String) ->String
{
    let importPasswordOption:NSDictionary = [kSecImportExportPassphrase as NSString:password]
    var items : CFArray?
    let secError:OSStatus = SecPKCS12Import(PKCS12Data, importPasswordOption, &items)
    
    if secError == errSecSuccess {
        return "0"
    }
    return "1"
    

}

//
public func convertSecKeyToBase64(_ inputKey: SecKey)-> String{
    guard let KeyData = SecKeyCopyExternalRepresentation(inputKey, nil) else {
        NSLog("\tError obtaining export of public key.")
        return "Error obtaining export of public key."
    }
    
    let KeyNSData = NSData(data: KeyData as Data)
    let KeyBase64Str = KeyNSData.base64EncodedString()
    //print(KeyBase64Str)
    return KeyBase64Str
}



public func convertSecTrustToBase64(_ inputKey: SecTrust)-> String{
    
    let KeyData = SecTrustCopyExceptions(inputKey)
    
    let KeyNSData = NSData(data: KeyData as Data)
    let KeyBase64Str = KeyNSData.base64EncodedString()
    //print(KeyBase64Str)
    return KeyBase64Str
}

public func convertAnyObjToBase64(_ anyObj: AnyObject)-> String{
    
    let KeyNSData = NSData(data: anyObj as! Data)
    let KeyBase64Str = KeyNSData.base64EncodedString()
    //print(KeyBase64Str)
    return KeyBase64Str
}

//
public func rsa_CertChain_from_data_(_ keyData:Data, withPassword password:String) -> SecCertificate? {
    var Cert: SecCertificate? = nil
    let options : [String:String] = [kSecImportExportPassphrase as String:password]
    var items : CFArray?
    if SecPKCS12Import(keyData as CFData, options as CFDictionary, &items) == errSecSuccess {
        //            print("items:\(CFArrayGetCount(items))")
        if CFArrayGetCount(items) > 0 {
           
            let d = unsafeBitCast(CFArrayGetValueAtIndex(items, 0),to: CFDictionary.self)
            print(d)
            let k = Unmanaged.passUnretained(kSecImportItemIdentity as NSString).toOpaque()
            print(k)
            let v = CFDictionaryGetValue(d, k)
            print(v)
             //               print("identity:\(identity)")
            let secIdentity = unsafeBitCast(v, to: SecIdentity.self)
                            //print("secIdentity:\(secIdentity)")
            if SecIdentityCopyCertificate(secIdentity, &Cert) == errSecSuccess {
                return Cert
            }
            
            
        }
    }
    
    
    return nil
}


public func xx (SecCert:SecCertificate)->SecKey {
    let Cert:SecKey?
    Cert = SecCertificateCopyKey(SecCert)
    return Cert!
}

public func yy(SecCert:SecCertificate)->SecKey{
    let Cert:SecKey?
    Cert = SecCertificateCopyPublicKey(SecCert)
    return Cert!
}

//


public func Get_CertKey(d:Data, withPassword:String)->String{
    let Cert: SecCertificate =  rsa_CertChain_from_data_(d ,withPassword: withPassword)!
    print("Cert : \(Cert)")
    let CertValue : SecKey = xx(SecCert: Cert)
    //print("CertValue : \(CertValue)")
    let CertB64 = convertSecKeyToBase64(CertValue)
    //print("CertValueB64 : \(CertB64)")
    return CertB64
}

public func Get_ChainKey(d:Data, withPassword:String)->String{
    let Chain: SecCertificate =  rsa_CertChain_from_data_(d ,withPassword: withPassword)!
    let ChainValue : SecKey = yy(SecCert: Chain)
    let ChainB64 = convertSecKeyToBase64(ChainValue)
    return ChainB64}

/// publicKey
public func rsa_publickey_from_data_(_ keyData:Data) -> SecKey?{
    if let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, keyData as CFData) {
        let policy = SecPolicyCreateBasicX509()
        var trust : SecTrust?
        if SecTrustCreateWithCertificates(certificate, policy, &trust) == errSecSuccess {
            var trustResultType : SecTrustResultType = SecTrustResultType.invalid
            if SecTrustEvaluate(trust!, &trustResultType) == errSecSuccess {
                return SecTrustCopyKey(trust!)
            }
        }
    }
    return nil

}

/// get private key
public func rsa_privatekey_from_data(_ keyData:Data, withPassword password:String) -> SecKey? {
//    var privateKey: SecKey? = nil
//    let options : [String:String] = [kSecImportExportPassphrase as String:password]
//    var items : CFArray?
//    if SecPKCS12Import(keyData as CFData, options as CFDictionary, &items) == errSecSuccess {
//        //            print("items:\(CFArrayGetCount(items))")
//        if CFArrayGetCount(items) > 0 {
//            let d = unsafeBitCast(CFArrayGetValueAtIndex(items, 0),to: CFDictionary.self)
//            let k = Unmanaged.passUnretained(kSecImportItemIdentity as NSString).toOpaque()
//            let v = CFDictionaryGetValue(d, k)
//            //                print("identity:\(identity)")
//            let secIdentity = unsafeBitCast(v, to: SecIdentity.self)
//                            print("secIdentity:\(secIdentity)")
//            if SecIdentityCopyPrivateKey(secIdentity, &privateKey) == errSecSuccess {
//                print("privateKey : \(privateKey!)")
//                return privateKey
//            }
//
//
//        }
//    }
    
    var Cert: SecKey? = nil
    let options : [String:String] = [kSecImportExportPassphrase as String:password]
    var items : CFArray?
    if SecPKCS12Import(keyData as CFData, options as CFDictionary, &items) == errSecSuccess {
        //            print("items:\(CFArrayGetCount(items))")
        if CFArrayGetCount(items) > 0 {
           
            let d = unsafeBitCast(CFArrayGetValueAtIndex(items, 0),to: CFDictionary.self)
            print(d)
            let k = Unmanaged.passUnretained(kSecImportItemIdentity as NSString).toOpaque()
            print(k)
            let v = CFDictionaryGetValue(d, k)
            print(v)
             //               print("identity:\(identity)")
            let secIdentity = unsafeBitCast(v, to: SecIdentity.self)
                            //print("secIdentity:\(secIdentity)")
            if SecIdentityCopyPrivateKey(secIdentity, &Cert) == errSecSuccess {
                return Cert
            }
        }
    }
    
    return nil
}

public func GetidentityCertChain(data: Data, password: String) -> SecIdentity {

    var importResult: CFArray? = nil
    let err = SecPKCS12Import(
        data as NSData,
        [kSecImportExportPassphrase as String: password] as NSDictionary,
        &importResult
    )
//    let err == errSecSuccess else {
//        throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
//    }
    let identityDictionaries = importResult as! [[String:Any]]
    return identityDictionaries[0][kSecImportItemIdentity as String] as! SecIdentity
}


public func Getidentity(named name: String, password: String) throws -> SecIdentity {
    let url = Bundle.main.url(forResource: name, withExtension: "p12")!
    let data = try Data(contentsOf: url)
    var importResult: CFArray? = nil
    let err = SecPKCS12Import(
        data as NSData,
        [kSecImportExportPassphrase as String: password] as NSDictionary,
        &importResult
    )
    guard err == errSecSuccess else {
        throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
    }
    let identityDictionaries = importResult as! [[String:Any]]
    return identityDictionaries[0][kSecImportItemIdentity as String] as! SecIdentity
}


extension URLCredential {
  public convenience init?(PKCS12 thePKCS12:PKCS12) {
    if let identity = thePKCS12.identity_ {
      self.init(
        identity: identity,
        certificates: thePKCS12.certChain,
        persistence: URLCredential.Persistence.forSession)
        print("??????????????????????")
    }
    else { return nil }
  }
}
