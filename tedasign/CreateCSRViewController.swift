//
//  CreateCSRViewController.swift
//  tedasign
//
//  Created by Pawan Pankhao on 27/10/2564 BE.
//

import UIKit
import CertificateSigningRequest

class CreateCSRViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtORG: UITextField!
    @IBOutlet weak var txtORGUnit: UITextField!
    
    let userdefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backButtonDisplayMode = .minimal
        self.title = "สร้าง CSR"
        self.txtName.becomeFirstResponder()
    }
    
    @IBAction func createCSRBtnTapped(_ sender: Any) {
        if txtName.isFirstResponder {
            txtName.resignFirstResponder()
        }
        if txtORG.isFirstResponder {
            txtORG.resignFirstResponder()
        }
        if txtORGUnit.isFirstResponder {
            txtORGUnit.resignFirstResponder()
        }
        
        let name = txtName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let org = txtORG.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let orgUnit = txtORGUnit.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (name == "" ){
            let popUp = PopUpWithImageView(imageName: "warning", title: "กรุณาใส่ข้อมูลให้ครบ", okButtonString: "CLOSE")
            popUp.show()
            txtName.becomeFirstResponder()
            return
        }else if (org == "" ){
            let popUp = PopUpWithImageView(imageName: "warning", title: "กรุณาใส่ข้อมูลให้ครบ", okButtonString: "CLOSE")
            popUp.show()
            txtORG.becomeFirstResponder()
            return
        }else if (orgUnit == "" ){
            let popUp = PopUpWithImageView(imageName: "warning", title: "กรุณาใส่ข้อมูลให้ครบ", okButtonString: "CLOSE")
            popUp.show()
            txtORGUnit.becomeFirstResponder()
            return
        }else {
            
            self.createCSRwithRSA2048KeySha512(name: name, organizationName: org, organizationUnitName: orgUnit)
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil);
//            let vc = storyboard.instantiateViewController(withIdentifier: "UploadCSRViewController") as! UploadCSRViewController;
//            DispatchQueue.main.async {
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "CSRListViewController") as! CSRListViewController;
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            //testLoadKey()
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.isFirstResponder {
            let validString = CharacterSet(charactersIn: "!@#$%^&*()+{}[]|\"<>,.~`/:;?-=\\¥'£•¢")
            
            if (textField.textInputMode?.primaryLanguage == "emoji") || textField.textInputMode?.primaryLanguage == nil {
                return false
            }
            if let range = string.rangeOfCharacter(from: validString)
            {
                print(range)
                return false
            }
        }
        return true
    }
    
    func createCSRwithRSA2048KeySha512(name:String, organizationName:String, organizationUnitName:String) {
        let date = NSDate() // current date
        let unixtime = date.timeIntervalSince1970
        let runNumber = Int(unixtime)
        
        let tagPrivate = "com.csr.private.rsa.\(runNumber)"
        let tagPublic = "com.csr.public.rsa.\(runNumber)"
        print("tagPrivate = \(tagPrivate)")
        print("tagPublic = \(tagPublic)")
        let chainStatus = false
        let certStatus = false
        let fileName = "csr-\(runNumber).csr"
        let keyTag = "\(runNumber)"
        let name = txtName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        
        //let keyAlgorithm = KeyAlgorithm.rsa(signatureType: .sha512)
        let keyAlgorithm = KeyAlgorithm.rsa(signatureType: .sha256)
        let sizeOfKey = keyAlgorithm.availableKeySizes.last!

        let (potentialPrivateKey, potentialPublicKey) =
            self.generateKeysAndStoreInKeychain(keyAlgorithm, keySize: sizeOfKey,
                                                tagPrivate: tagPrivate, tagPublic: tagPublic)
        guard let privateKey = potentialPrivateKey,
            let publicKey = potentialPublicKey else {
                //XCTAssertNotNil(potentialPrivateKey, "Private key not generated")
                //XCTAssertNotNil(potentialPublicKey, "Public key not generated")
                return
        }

        let (potentialPublicKeyBits, potentialPublicKeyBlockSize) =
            self.getPublicKeyBits(keyAlgorithm,
                                  publicKey: publicKey, tagPublic: tagPublic)
        guard let publicKeyBits = potentialPublicKeyBits,
            potentialPublicKeyBlockSize != nil else {
            print("Private key bits not generated")
            print("Public key block size not generated")
                return
        }

        //Initiale CSR
        let csr = CertificateSigningRequest(commonName: name,
                                            organizationName: organizationName, organizationUnitName: organizationUnitName,
                                            countryName: "", stateOrProvinceName: "",
                                            localityName: "", emailAddress: "",
                                            description: "", keyAlgorithm: keyAlgorithm)
        //Build the CSR
        let csrBuild = csr.buildAndEncodeDataAsString(publicKeyBits, privateKey: privateKey)
        let csrBuild2 = csr.buildCSRAndReturnString(publicKeyBits, privateKey: privateKey)
        if let csrRegular = csrBuild {
            print("CSR string no header and footer")
            print(csrRegular)
            print("CSR contains no data")
        } else {
            print("CSR with header not generated")
        }
        if let csrWithHeaderFooter = csrBuild2 {
            print("CSR string with header and footer")
            print(csrWithHeaderFooter)
            
            // test Sign, Verify
            let data = "test".data(using: .utf8)! as CFData
            let signatureSign = DigitalSinatureSignx(privateKey: privateKey, value: data)!
            print("signatureSign = \(signatureSign)")
//
//            let data2 = "test".data(using: .utf8)! as CFData
//            var result = DigitalSinatureVerify(publicKey: publicKey, signature: signatureSign,value: data2)
//            print("result = \(result)")
//
            
            // test save data
            testSaveKey(privateKey: privateKey, publicKey: publicKey)
            
            let driveURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
            //icloud path
            let path = driveURL?.appendingPathComponent(fileName)
            
                try? csrWithHeaderFooter.write(to: path!, atomically: false, encoding: .utf8)
                print("saved file to \(path!)")
            
            //local path
            let filePath = FileManager.default.urls(for: .documentDirectory,
                                                                in: .userDomainMask)[0].appendingPathComponent(fileName)
            try? csrWithHeaderFooter.write(to: filePath, atomically: false, encoding: .utf8)
            print("saved local file to \(filePath)")
            
            let csrInfo = CSRInfo(name: name, fileName: fileName, chainStatus: chainStatus, certStatus: certStatus, date: runNumber, localPath: filePath, icloudPath: path!, signatureSign: signatureSign)
            
            //removeAllCSRInfo()
            
            addNewCSRInfo(info: csrInfo)
            
            
//            let items = getAllCSRInfo()
//            print("first item name = \(items.first?.name)")
//            print("first item fileName = \(items.first?.fileName)")
//            print("first item date = \(items.first?.mediumDateString())")
//            print("first item chainStatus = \(items.first?.chainStatus)")
//            print("first item certStatus = \(items.first?.certStatus)")
//            print("first item localPath = \(items.first?.localPath)")
//            print("first item icloudPath = \(items.first?.icloudPath)")
//            print("first item signatureSign = \(items.first?.signatureSign)")
            
            //XCTAssertTrue(csrBuild2!.contains("BEGIN"), "CSR string builder isn't complete")
        } else {
            print("CSR with header not generated")
        }
    }
    
    func addNewCSRInfo(info: CSRInfo){
        if self.userdefaults.data(forKey:"allCSR") != nil {
            // add one
            let encodedArray = self.userdefaults.data(forKey:"allCSR")
            var decodedArray = NSKeyedUnarchiver.unarchiveObject(with: encodedArray!) as! [CSRInfo]
            decodedArray.append(info)
            let updatedArray : NSData = NSKeyedArchiver.archivedData(withRootObject: decodedArray) as NSData
            self.userdefaults.setValue(updatedArray, forKey:"allCSR")
            self.userdefaults.synchronize()
        }else{
            // first item
            var array = [info]
            let encodedArray : NSData = NSKeyedArchiver.archivedData(withRootObject: array) as NSData
            self.userdefaults.setValue(encodedArray, forKey:"allCSR")
            self.userdefaults.synchronize()
        }
    }
    
    func getAllCSRInfo() -> [CSRInfo]{
        if self.userdefaults.data(forKey:"allCSR") != nil {
            let encodedArray = self.userdefaults.data(forKey:"allCSR")
            var decodedArray = NSKeyedUnarchiver.unarchiveObject(with: encodedArray!) as! [CSRInfo]
            print("found allCSR = \(decodedArray)")
            return decodedArray
        }else{
            print("not found allCSR in userdefaults")
        }
        return []
    }
    
    func removeAllCSRInfo(){
        if self.userdefaults.data(forKey:"allCSR") != nil {
            self.userdefaults.removeObject(forKey: "allCSR")
            self.userdefaults.synchronize()
        }
    }
    
    private func testSaveKey(privateKey: SecKey, publicKey: SecKey){
        let data = "test".data(using: .utf8)! as CFData
        var signatureSign = DigitalSinatureSignx(privateKey: privateKey, value: data)!
        print("signatureSign = \(signatureSign)")
        self.userdefaults.setValue(signatureSign, forKey: "signature")
        
        var error:Unmanaged<CFError>?
        if let cfdata = SecKeyCopyExternalRepresentation(publicKey, &error) {
           let data:Data = cfdata as Data
           let b64Key = data.base64EncodedString()
            self.userdefaults.setValue(b64Key, forKey: "public")
        }
        if let cfdata = SecKeyCopyExternalRepresentation(privateKey, &error) {
           let data:Data = cfdata as Data
           let b64Key = data.base64EncodedString()
            self.userdefaults.setValue(b64Key, forKey: "private")
        }
        //self.save(fileData, key: "fileData", value: fileData)
    }
    
    private func testLoadKey(){
        print("privateKey = \(String(describing: self.userdefaults.value(forKey: "private")))")
        print("publicKey = \(String(describing: self.userdefaults.value(forKey: "public")))")
        print("signature = \(String(describing: self.userdefaults.value(forKey: "signature")))")
        let pbKey = String(describing: self.userdefaults.value(forKey: "public")!)
        let pvKey = String(describing: self.userdefaults.value(forKey: "private")!)
        let sig = self.userdefaults.value(forKey: "signature") as! Data
//        do {
//            let publicKey = try PublicKey(base64Encoded: pbKey)
//            print("publicKey = \(publicKey)")
//        } catch {
//            print("error = \(error.localizedDescription)")
//        }
        let data2 = Data(base64Encoded: pbKey)
        let keyDict:[NSObject:NSObject] = [
           kSecAttrKeyType: kSecAttrKeyTypeRSA,
           kSecAttrKeyClass: kSecAttrKeyClassPublic,
           kSecAttrKeySizeInBits: NSNumber(value: 256),
           kSecReturnPersistentRef: true as NSObject
        ]
        guard let publicKey = SecKeyCreateWithData(data2! as CFData, keyDict as CFDictionary, nil) else {
            return
        }
        print("publicKey = \(publicKey)")
        
        let data3 = Data(base64Encoded: pvKey)
        let keyDict3:[NSObject:NSObject] = [
           kSecAttrKeyType: kSecAttrKeyTypeRSA,
           kSecAttrKeyClass: kSecAttrKeyClassPrivate,
           kSecAttrKeySizeInBits: NSNumber(value: 256),
           kSecReturnPersistentRef: true as NSObject
        ]
        guard let privateKey = SecKeyCreateWithData(data3! as CFData, keyDict3 as CFDictionary, nil) else {
            return
        }
        print("publicKey = \(publicKey)")
        print("privateKey = \(privateKey)")
        
        let data4 = "test".data(using: .utf8)! as CFData
        var result = DigitalSinatureVerify(publicKey: publicKey, signature: sig,value: data4)
        print("result = \(result)")
    }
    
    func DigitalSinatureSignx(privateKey: SecKey, value: CFData) -> Data?{
        var error: Unmanaged<CFError>?
        return  SecKeyCreateSignature(privateKey,.rsaSignatureMessagePKCS1v15SHA256,value,&error) as Data?
        
    }

    func DigitalSinatureVerify(publicKey: SecKey, signature: Data,value: CFData) -> Bool?{
        var error: Unmanaged<CFError>?
        return SecKeyVerifySignature(publicKey, .rsaSignatureMessagePKCS1v15SHA256, value, signature as CFData, &error)
        
    }
    
    func generateKeysAndStoreInKeychain(_ algorithm: KeyAlgorithm, keySize: Int,
                                            tagPrivate: String, tagPublic: String) -> (SecKey?, SecKey?) {
            let publicKeyParameters: [String: Any] = [
                String(kSecAttrIsPermanent): true,
                String(kSecAttrAccessible): kSecAttrAccessibleAfterFirstUnlock,
                String(kSecAttrApplicationTag): tagPublic.data(using: .utf8)!
            ]

            var privateKeyParameters: [String: Any] = [
                String(kSecAttrIsPermanent): true,
                String(kSecAttrAccessible): kSecAttrAccessibleAfterFirstUnlock,
                String(kSecAttrApplicationTag): tagPrivate.data(using: .utf8)!
            ]

            #if !targetEnvironment(simulator)
                //This only works for Secure Enclave consisting of 256 bit key,
                //note, the signatureType is irrelevant for this check
                if algorithm.type == KeyAlgorithm.ec(signatureType: .sha1).type {
                    let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                                 kSecAttrAccessibleAfterFirstUnlock,
                                                                 .privateKeyUsage,
                                                                 nil)!   // Ignore error
                    privateKeyParameters[String(kSecAttrAccessControl)] = access
                }
            #endif

            //Define what type of keys to be generated here
            var parameters: [String: Any] = [
                String(kSecAttrKeyType): algorithm.secKeyAttrType,
                String(kSecAttrKeySizeInBits): keySize,
                String(kSecReturnRef): true,
                String(kSecPublicKeyAttrs): publicKeyParameters,
                String(kSecPrivateKeyAttrs): privateKeyParameters
            ]

            #if !targetEnvironment(simulator)
                //iOS only allows EC 256 keys to be secured in enclave.
                //This will attempt to allow any EC key in the enclave,
                //assuming iOS will do it outside of the enclave if it
                //doesn't like the key size, note: the signatureType is irrelavent for this check
                if algorithm.type == KeyAlgorithm.ec(signatureType: .sha1).type {
                    parameters[String(kSecAttrTokenID)] = kSecAttrTokenIDSecureEnclave
                }
            #endif

            //Use Apple Security Framework to generate keys, save them to application keychain
            var error: Unmanaged<CFError>?
            let privateKey = SecKeyCreateRandomKey(parameters as CFDictionary, &error)
            if privateKey == nil {
                print("Error creating keys occured: \(error!.takeRetainedValue() as Error), keys weren't created")
                return (nil, nil)
            }
        
        print("privatekey = \(privateKey)")

            //Get generated public key
            let query: [String: Any] = [
                String(kSecClass): kSecClassKey,
                String(kSecAttrKeyType): algorithm.secKeyAttrType,
                String(kSecAttrApplicationTag): tagPublic.data(using: .utf8)!,
                String(kSecReturnRef): true
            ]

            var publicKeyReturn: CFTypeRef?
            let result = SecItemCopyMatching(query as CFDictionary, &publicKeyReturn)
            if result != errSecSuccess {
                print("Error getting publicKey fron keychain occured: \(result)")
                return (privateKey, nil)
            }
            // swiftlint:disable:next force_cast
            let publicKey = publicKeyReturn as! SecKey?
            return (privateKey, publicKey)
        }
    
    func getPublicKeyBits(_ algorithm: KeyAlgorithm, publicKey: SecKey, tagPublic: String) -> (Data?, Int?) {

            //Set block size
            let keyBlockSize = SecKeyGetBlockSize(publicKey)
            //Ask keychain to provide the publicKey in bits
            let query: [String: Any] = [
                String(kSecClass): kSecClassKey,
                String(kSecAttrKeyType): algorithm.secKeyAttrType,
                String(kSecAttrApplicationTag): tagPublic.data(using: .utf8)!,
                String(kSecReturnData): true
            ]

            var tempPublicKeyBits: CFTypeRef?
            var _ = SecItemCopyMatching(query as CFDictionary, &tempPublicKeyBits)

            guard let keyBits = tempPublicKeyBits as? Data else {
                return (nil, nil)
            }

            return (keyBits, keyBlockSize)
        }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
