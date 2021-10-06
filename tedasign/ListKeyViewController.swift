//
//  ListKeyViewController.swift
//  TEDASign
//
//  Created by Error on 2/7/2564 BE.
//

import UIKit
import KeychainAccess
import LocalAuthentication
import GTMSessionFetcher

class ListKeyViewController: UIViewController, UITableViewDataSource ,UITableViewDelegate {
    
    var ListKeyView:ListKeyViewController!
    var mListKey:[String] = []
    var PageShowType:String = ""
    let userdefaults = UserDefaults.standard

    @IBOutlet weak var tablreView: UITableView!
    
    var qrcode = ""
    let progressHUD = ProgressHUD(text: "Loading...")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select Signature"
        
        self.view.addSubview(progressHUD)
        progressHUD.hide()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tablreView.delegate = self
           self.tablreView.dataSource = self
        loadListKey()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mListKey.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
              
              // set the text from the data model
              cell.textLabel?.text = self.mListKey[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        
        let boldText  = "Last update: "
        let normalText = getDate(tagKeyName: self.mListKey[indexPath.row])
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 11)]
        let attributedString = NSMutableAttributedString(string:normalText)
        let boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
        boldString.append(attributedString)
        cell.detailTextLabel?.attributedText = boldString
//        cell.detailTextLabel?.attributedText = "Last update: "+getDate(tagKeyName: self.mListKey[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        MainView.jsonKeyDetail = mListKey[indexPath.row]
        if(userdefaults.bool(forKey: "isAuthFirst")){
            if(AppDelegate.isFirst){
                if(touchIDAuthenticationFirst(keyname: self.mListKey[indexPath.row])){
                    
                }
            }else{
                Signing2Server(keyname: self.mListKey[indexPath.row])
            }
        } else {
            if(AppDelegate.isFirst){
                if(touchIDAuthentication(keyname: self.mListKey[indexPath.row])){
                    
                }
            }else{
                Signing2Server(keyname: self.mListKey[indexPath.row])
            }
        }
        
       
     
//        let PVK: SecKey = rsa_privatekey_from_data(d as Data, withPassword: "123456789")!
//        print("Private Key : ")
//        let PVKBase64 = convertSecKeyToBase64(PVK)
//        print(PVKBase64)
//
//
//        let x: SecKey = rsa_publickey_from_data_(d as Data)!
//        print("cert : \(x)")
//        let xB64 = convertSecKeyToBase64(x)
//        print("xxxx : \(xB64)")
//
//        let Cert: SecCertificate =  rsa_CertChain_from_data_(d as Data,withPassword: "123456789")!
//        print("Cert : \(Cert)")
//        let CertValue : SecKey = xx(SecCert: Cert)
//        print("CertValue : \(CertValue)")
//        let CertB64 = convertSecKeyToBase64(CertValue)
//        print("CertValueB64 : \(CertB64)")
//
//        let pulKey: SecKey = yy(SecCert: Cert)
//        print("pulKey : \(pulKey)")
//        let pulKeyB64 = convertSecKeyToBase64(pulKey)
//        print("pulKeyB64 : \(pulKeyB64)")
        
        
        
        
        //
//        dismiss(animated: true, completion: nil)
//
//        // incase use sign process
//        if(PageShowType == ""){
//
//
//            let context = LAContext()
//            var error: NSError?
//
//            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//                let reason = "Identify yourself!"
//
//                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
//                    [weak self] success, authenticationError in
//
//                    DispatchQueue.main.async {
//                        if success {
////                            self?.MainView.showListKeyView()
//                        } else {
//                            // error
//                        }
//                    }
//                }
//            } else {
//                // no biometry
//
//                let reason = "Identify yourself! passcode"
//
//                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
//                    [weak self] success, authenticationError in
//
//                    DispatchQueue.main.async {
//                        if success {
////                            self?.MainView.showListKeyView()
//                        } else {
//                            // error
//                        }
//                    }
//                }
//            }
//
//        }
//        // in case backup
//        else if(PageShowType == "backupkeyfile"){
////            MainView.dataImport = getDataKey(keychain: keychain_, tagKeyName: mListKey[indexPath.row])
////            MainView.Keypassword = getPasswordFile(keychain: keychain_, tagKeyName: mListKey[indexPath.row])
////            MainView.CreatePassForBackup()
//
//        }
        
    }
    
    
    //
    func loadListKey() {
        mListKey = SelectAllKey()
        print(mListKey)
    }
     
    
    
    func touchIDAuthenticationFirst(keyname:String)-> Bool{
        print("touchIDAuthenticationFirst")
        let localAuthenticationContext = LAContext()
        var returnValue: Bool = false

        localAuthenticationContext.localizedFallbackTitle = "Please use your Passcode"
        var authorizationError: NSError?
        let reason = "Authentication is required for you to continue"
        if localAuthenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authorizationError) {
            
            let biometricType = localAuthenticationContext.biometryType == LABiometryType.faceID ? "Face ID" : "Touch ID"
            print("Supported Biometric type is: \( biometricType )")
            
            localAuthenticationContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, evaluationError) in
             
                if success {
                    print("Success")
                    self.userdefaults.set(true,forKey: "isAuth")
                    self.userdefaults.set(false,forKey: "isAuthFirst")
                    DispatchQueue.main.async {
                        DispatchQueue.main.async {
                                self.Signing2Server(keyname: keyname)
                        }
                    }
                    AppDelegate.isFirst = false
                    returnValue = true
                } else {
                    print("Error \(evaluationError!)")
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    self.userdefaults.set(false,forKey: "isAuth")
                    self.userdefaults.set(false,forKey: "isAuthFirst")
                    AppDelegate.isAuth = false
                    AppDelegate.isAuthFirst = false
                    returnValue = false

                }
            }
              
        } else {
            AppDelegate.isAuth = false
            AppDelegate.isAuthFirst = false
            self.userdefaults.set(false,forKey: "isAuth")
            self.userdefaults.set(false,forKey: "isAuthFirst")
            print("User has not enrolled into using Biometrics")
        }
        
        return returnValue
    }
    
    
    func touchIDAuthentication(keyname:String)-> Bool{
        let localAuthenticationContext = LAContext()
        var returnValue: Bool = false

        localAuthenticationContext.localizedFallbackTitle = "Please use your Passcode"
        var authorizationError: NSError?
        let reason = "Authentication is required for you to continue"
        if localAuthenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &authorizationError) {
            
            let biometricType = localAuthenticationContext.biometryType == LABiometryType.faceID ? "Face ID" : "Touch ID"
            print("Supported Biometric type is: \( biometricType )")
            
            localAuthenticationContext.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason) { (success, evaluationError) in
                if success {
                    DispatchQueue.main.async {
                            self.Signing2Server(keyname: keyname)
                    } // // .End DispatchQueue.main.async
                    print("Success")
                    AppDelegate.isFirst = false
                    returnValue = true
                } else {
                    returnValue = false
                    print("Error \(evaluationError!)")
                }
            }
              
        } else {
            print("User has not enrolled into using Biometrics")
        }
        
        return returnValue
    }
    
    
    func bioCheck(keyname:String) -> Bool{
        let context = LAContext()
        var error: NSError?
        var returnValue: Bool = false
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        // confirm message
                        self?.Signing2Server(keyname: keyname)
                        // .End conform message
                    } else {
                        
                        // face not match
                        let reason = "Identify yourself! by passcode"
                        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                            [weak self] success, authenticationError in

                            DispatchQueue.main.async {
                                if success {
                                    self?.Signing2Server(keyname: keyname)
                                } else {
                                    returnValue = false
                                }
                            } // // .End DispatchQueue.main.async
                        
                        } // .End context.evaluatePolicy
                    }
                } // // .End DispatchQueue.main.async
             
            }
        } else {
            
            // no biometry
            let reason = "Identify yourself! by passcode"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                [weak self] success, authenticationError in


                DispatchQueue.main.async {
                    if success {
                        self?.Signing2Server(keyname: keyname)
                    } else {
                        returnValue = false
                    }
                } // // .End DispatchQueue.main.async
                
            } // .End context.evaluatePolicy
        }
        return returnValue
    }

    
    func Signing2Server(keyname:String) {
        //
        progressHUD.show()
        let dataP12 = getDataKey( tagKeyName: keyname)
        let pass = getPasswordFile( tagKeyName: keyname)
//        let pkcs = PKCS12Test(PKCS12Data: data, password: pass)
        
        let strQRValArr = qrcode.components(separatedBy: ";")
        let str_signing_endpoint    = strQRValArr[0]
        let str_request_id = strQRValArr[1]
        let str_ref_number = strQRValArr[3]
        let str_requesting_token = strQRValArr[2]
        
        //create the url with NSURL
        let url = URL(string: str_signing_endpoint+"/"+str_request_id)!
        //create the session object
        let session = URLSession.shared

        //now create the Request object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        //
        let certChain = PKCS12.init(PKCS12Data: dataP12, password:pass).getCertChain()
        
        let cert_:String = certChain[0]
        let chain_:String = certChain[1]
//        let cert_:String = pkcs.certChain?[0] as! String
//        let chain_:String = pkcs.certChain?[1] as! String
        let parameters = ["key":["cert": cert_,"chains": chain_]] as [String : Any]
//        print(qrcode)
//        print(str_requesting_token)
//        print(url)
//        print(parameters)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to data object and set it as request body
        } catch let error {
            print("error.localizedDescription")
            print(error.localizedDescription)
        }

        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue( str_requesting_token, forHTTPHeaderField: "Token")

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }

            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                    return
                }
                print(json)
                
                if (json["result"] as! String == "accept") {
                    
                    let signedInfo = json["signedInfo"] as! String
                    var sign = Data(base64Encoded: signedInfo)
                    let privateKey = rsa_privatekey_from_data(dataP12 as Data, withPassword: pass)
                    let signature = self.DigitalSinatureSignx(privateKey: privateKey!, value:sign!)
                    let decodedString = signature!.base64EncodedString()
//                    let decodedString = String(data: signature!, encoding: .utf8)!
                    self.SigningSubmitServer(keyname: keyname, signature: decodedString)
                        
                } else{
                    
//                    print(json["description"] as! String)
//                    let alert = UIAlertController(title: "Failed", message: json["description"] as! String, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                    DispatchQueue.main.async {
//                        self.present(alert, animated: true, completion: nil)
//                    }
                    
                    let popUp = PopUpWithImageView(imageName: "warning", title: json["description"] as! String, okButtonString: "OK")
                    popUp.show()
                  
                }

            } catch let error {
                print("catch error.localizedDescription")
                print(error.localizedDescription)
            }
        })

        task.resume()
    }
    
    func DigitalSinatureSignx(privateKey: SecKey, value: Data) -> Data?
    {
        var error: Unmanaged<CFError>?
        return  SecKeyCreateSignature(privateKey,.rsaSignatureMessagePKCS1v15SHA256,
                                      value as CFData,
                                                     &error) as Data?
    }
    
    func SigningSubmitServer(keyname:String,signature:String) {
        
        let strQRValArr = qrcode.components(separatedBy: ";")
        let str_signing_endpoint    = strQRValArr[0]
        let str_request_id = strQRValArr[1]
        let str_requesting_token = strQRValArr[2]
        
        //create the url with NSURL
        let url = URL(string: str_signing_endpoint+"/"+str_request_id+"/submit")!
        //create the session object
        let session = URLSession.shared

        //now create the Request object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
//        let cert_:String = pkcs.certChain?[0] as! String
//        let chain_:String = pkcs.certChain?[1] as! String
        let parameters = ["signature":signature] as [String : Any]
//        print(qrcode)
//        print(str_requesting_token)
//        print(url)
        print(parameters)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to data object and set it as request body
        } catch let error {
            print("error.localizedDescription")
            print(error.localizedDescription)
        }

        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue( str_requesting_token, forHTTPHeaderField: "Token")

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }

            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                    return
                }
                print(json)
                
                if (json["result"] as! String == "accept") {
                    self.progressHUD.hide()
//
//                    let alert = UIAlertController(title: "คุณได้ลงนามเอกสาร", message: "เรียบร้อย\nวันที่ "+CurrentTimeStamp(dateFormatter: "dd-MM-yyyy HH:mm"), preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "รับทราบ", style: .cancel, handler:{_ in
////                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
//                        self.navigationController?.popToRootViewController(animated: true)
//                    }))
//                    DispatchQueue.main.async {
//                        self.present(alert, animated: true, completion: nil)
//                    }
                    
                    DispatchQueue.main.async {
                        
                        let popUp = PopUpFinishSign(title: "คุณได้ลงนามเอกสาร", dateString: "วันที่ "+CurrentTimeStamp(dateFormatter: "dd-MM-yyyy HH:mm"), acceptButtonString: "รับทราบ", cancelButtonString: "ปิดแจ้งเตือน", touchAccept: {
                            self.navigationController?.popToRootViewController(animated: true)

//                            if let url = URL(string: "https://api-uat.teda.th/tedasign/?request_id=\(strQRValArr[1])") {
//                                UIApplication.shared.open(url)
//                            }
                        }, touchCancel: {
                            self.navigationController?.popToRootViewController(animated: true)

                        })
                        popUp.show()

                    }
                    
                } else{
                    self.progressHUD.hide()
//                    print(json["description"] as! String)
//                    let alert = UIAlertController(title: "Failed", message: json["description"] as! String, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                    DispatchQueue.main.async {
//                        self.present(alert, animated: true, completion: nil)
//                    }
                    DispatchQueue.main.async {
                        
                        let popUp = PopUpWithImageView(imageName: "warning", title: json["description"]  as! String, okButtonString: "CLOSE")
                        popUp.show()
                    }
                  
                }

            } catch let error {
                self.progressHUD.hide()
                print("catch error.localizedDescription")
                print(error.localizedDescription)
            }
        })

        task.resume()
    }
    
    func dismissViewControllers() {

        guard let vc = self.presentingViewController else { return }

        while (vc.presentingViewController != nil) {
            vc.dismiss(animated: true, completion: nil)
        }
    }
}

extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

