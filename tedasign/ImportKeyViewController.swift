//
//  ImportKeyViewController.swift
//  tedamobilesigning
//
//  Created by Prawit Phiwhom on 5/4/2564 BE.
//

import UIKit
import LocalAuthentication
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

class ImportKeyViewController: UIViewController,UITextFieldDelegate {
    
    let service = GTLRDriveService()
    var drive: ATGoogleDrive?
    var dataImport:NSData!
    var isRestore = false
    let userdefaults = UserDefaults.standard

    // check authen
    let context = LAContext()
    var error: NSError?
    var nameKey = ""
    
    @IBOutlet weak var insertNameContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var txtInsertNameKey: UITextField!
    @IBOutlet weak var eyeButton: UIButton!

    @IBOutlet weak var inputPassContainerView: UIView!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var txtInputPass: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Import P12 password"
        txtInsertNameKey.delegate = self
        txtInputPass.delegate = self
        txtInsertNameKey.becomeFirstResponder()
        self.navigationItem.backButtonDisplayMode = .minimal
        self.eyeButton.setImage(UIImage(named: "iconEye.png"), for: .normal)
       
    }
    
    
    //    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    //        /* So first we take the inverted set of the characters we want to keep,
    //           this will act as the separator set, i.e. those characters we want to
    //           take out from the user input */
    //        let inverseSet = NSCharacterSet(charactersIn:"ABCDEFGHIJKLMNOPQRSTUVWXUZ").inverted
    //
    //        /* We then use this separator set to remove those unwanted characters.
    //           So we are basically separating the characters we want to keep, by those
    //           we don't */
    ////        let components = string.componentsSeparatedByCharactersInSet(inverseSet)
    //        let components = string.components(separatedBy: inverseSet)
    //
    //        /* We then join those characters together */
    //        let filtered = components.joined(separator: "")
    //
    //        return string == filtered
    //    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtInsertNameKey {
            insertNameContainerView.borderColor = UIColor(rgb: 0x0047B1)
            nameLabel.textColor = .black
        } else if textField == txtInputPass {
            inputPassContainerView.borderColor = UIColor(rgb: 0x0047B1)
            passwordLabel.textColor = .black
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtInsertNameKey {
            insertNameContainerView.borderColor = UIColor(rgb: 0x000000, alpha: 0.6)
            nameLabel.textColor = UIColor(rgb: 0x000000, alpha: 0.4)
        } else if textField == txtInputPass {
            inputPassContainerView.borderColor = UIColor(rgb: 0x000000, alpha: 0.6)
            passwordLabel.textColor = UIColor(rgb: 0x000000, alpha: 0.4)
        }

        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.isFirstResponder && textField == txtInsertNameKey {
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
    
    func ConnectGoolgeAccount() {
        //Google
//        GIDSignIn.sharedInstance()?.signOut()
//        //
//        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance().uiDelegate = self
//        //        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDriveFile]
//        GIDSignIn.sharedInstance()?.scopes = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDrive, kGTLRAuthScopeDriveAppdata, kGTLRAuthScopeDriveMetadata, kGTLRAuthScopeDriveScripts]
//        GIDSignIn.sharedInstance().signInSilently()
//        //
//        drive = ATGoogleDrive(service)
//
//        //Sign to google account
//        GIDSignIn.sharedInstance()?.signIn()
        
//        GIDSignIn.sharedInstance.signOut()
//        let additionalScopes = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDrive, kGTLRAuthScopeDriveAppdata, kGTLRAuthScopeDriveMetadata, kGTLRAuthScopeDriveScripts]
//        GIDSignIn.sharedInstance.addScopes(additionalScopes, presenting: self) { user, error in
//            guard error == nil else { return }
//            guard let _ = user else { return }
//        }
        //
        drive = ATGoogleDrive(service)
        
        //Sign to google account
        //GIDSignIn.sharedInstance()?.signIn()
        GIDSignIn.sharedInstance.signIn(with: AppDelegate.signInConfig, presenting: self) { user, error in
            if (error == nil) {
                //self.service.authorizer = user?.authentication.fetcherAuthorizer()
                print("Login Successed!")
                
                let additionalScopes = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDriveAppdata]
                GIDSignIn.sharedInstance.addScopes(additionalScopes, presenting: self) { user, error in
                    guard error == nil else { self.navigationController?.popViewController(animated: true); return }
                    guard let user = user else { self.navigationController?.popViewController(animated: true); return }

                    self.service.authorizer = user.authentication.fetcherAuthorizer()
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
                    let vc = storyboard.instantiateViewController(withIdentifier: "BackupViewController") as! BackupViewController;
                    vc.dataImport = self.dataImport
                    vc.name = self.nameKey
                    vc.drive = self.drive
                    DispatchQueue.main.async {
                        //               self.present(vc, animated: true, completion: nil)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } else {
                print("Login Failed")
                self.service.authorizer = nil
                print(user)
                print(error?.localizedDescription)
                if(error?.localizedDescription == "The user canceled the sign-in flow."){
                    self.navigationController?.popViewController(animated: true)
                }
            }
          }
    }
    
    @IBAction func touchShowOrHidePasswordButton(_ sender: Any) {
        print("savedText:", txtInputPass.isSecureTextEntry)
        if(txtInputPass.isSecureTextEntry){
            self.eyeButton.setImage(UIImage(named: "iconEyeDis.png"), for: .normal)
        } else {
            self.eyeButton.setImage(UIImage(named: "iconEye.png"), for: .normal)
        }

        self.txtInputPass.isSecureTextEntry.toggle()
    }
    
    @IBAction func ImportKey(_ sender: Any) {
        if txtInsertNameKey.isFirstResponder {
            txtInsertNameKey.resignFirstResponder()
        }
        if txtInputPass.isFirstResponder {
            txtInputPass.resignFirstResponder()
        }
        let name = txtInsertNameKey.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = txtInputPass.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //Check Input
        if (name == "" ){
//            let alert = UIAlertController(title: "Warning!", message: "กรุณาใส่ข้อมูลให้ครบ", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "CLOSE", style: .default, handler: nil))
//            txtInsertNameKey.becomeFirstResponder()
//            self.present(alert, animated: true)
//
            let popUp = PopUpWithImageView(imageName: "warning", title: "กรุณาใส่ข้อมูลให้ครบ", okButtonString: "CLOSE")
            popUp.show()
            txtInsertNameKey.becomeFirstResponder()
            return
        }else if (pass == ""){
//            let alert = UIAlertController(title: "Warning!", message: "กรุณาใส่ข้อมูลให้ครบ", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "CLOSE", style: .default, handler: nil))
//            txtInputPass.becomeFirstResponder()
//            self.present(alert, animated: true)
            
            let popUp = PopUpWithImageView(imageName: "warning", title: "กรุณาใส่ข้อมูลให้ครบ", okButtonString: "CLOSE")
            popUp.show()
            txtInsertNameKey.becomeFirstResponder()
            return
        }
        
        //check file
        let reC = CheckFileImportP12(PKCS12Data: dataImport, password: pass)
        if(reC == "1"){
//            let alert = UIAlertController(title: "Warning!", message: "Wrong password or corrupted file", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true)
            let popUp = PopUpWithImageView(imageName: "x_circle", title: "Wrong password or corrupted file", okButtonString: "OK")
            popUp.show()
            return
        }
        
        print("userdefaults.isAuthFirst" ,userdefaults.bool(forKey: "isAuthFirst"))
        print("userdefaults.isAuth" ,userdefaults.bool(forKey: "isAuth"))

        print("AppDelegate =",AppDelegate.isFirst)
        if(userdefaults.bool(forKey: "isAuthFirst")){
            touchIDAuthenticationFirst()
        } else {
            touchIDAuthentication()
        }
        
//        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//            let reason = "Identify yourself!"
//
//            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
//                [weak self] success, authenticationError in
//
//
//                DispatchQueue.main.async {
//                    if success {
//                        // confirm message
//                        self?.showConfirmBackupOrNot()
//                        // .End conform message
//                    } else {
//
//                        let message: String
//
//                        switch authenticationError {
//                        case LAError.authenticationFailed?:
//                            message = "There was a problem verifying your identity."
//                        case LAError.userCancel?:
//                            message = "You pressed cancel."
//                        case LAError.userFallback?:
//                            message = "You pressed password."
//                        case LAError.biometryNotAvailable?:
//                            message = "Face ID/Touch ID is not available."
//                        case LAError.biometryNotEnrolled?:
//                            message = "Face ID/Touch ID is not set up."
//                        case LAError.biometryLockout?:
//                            message = "Face ID/Touch ID is locked."
//                        default:
//                            message = "Face ID/Touch ID may not be configured"
//                        }
//
////                        let alertStatusImport = UIAlertController(title: message, message: "", preferredStyle: .alert)
////                        alertStatusImport.addAction(UIAlertAction(title: "CLOSE", style: .cancel, handler: { alert in
////                            //
////                            DispatchQueue.main.async {
////                                self!.dismiss(animated: true, completion: {
////
////                                    self!.navigationController?.popToRootViewController(animated: true)
////                                })
////
////                            } //
////                            // end
////                        }))
////
////                        self!.present(alertStatusImport, animated: true)
//
//                        let popUp = PopUpWithImageView(imageName: "checkmark_circle", title: message, okButtonString: "CLOSE") {
//                            self!.navigationController?.popToRootViewController(animated: true)
//                        }
//                        popUp.show()
//                        // face not match 189031
//
//                    }
//                } // // .End DispatchQueue.main.async
//            }
//        } else {
//
//            let popUp = PopUpWithImageView(imageName: "checkmark_circle", title: "Use Face ID to authentication.", okButtonString: "CLOSE") {
//                self.navigationController?.popToRootViewController(animated: true)
//            }
//            popUp.show()
//
//        }
    }
    // end check authen
    // .End ImportKey
  
     
    
    
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
                         
                        // .End conform message
                    } else {
                        
                        // face not match
                        let reason = "Identify yourself! by passcode"
                        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                            [weak self] success, authenticationError in

                            DispatchQueue.main.async {
                                if success {
                                    
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
//                        self?.Signing2Server(keyname: keyname)
                    } else {
                        returnValue = false
                    }
                } // // .End DispatchQueue.main.async
                
            } // .End context.evaluatePolicy
        }
        return returnValue
    }

    
     
    func touchIDAuthentication()-> Bool{
        print("touchIDAuthentication")
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
                    print("Success")
                    returnValue = true
                    DispatchQueue.main.async {
                        self.showConfirmBackupOrNot()
                    }
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
    
    
    func touchIDAuthenticationFirst()-> Bool{
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
                        self.showConfirmBackupOrNot()
                    }
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
    
    
    
    
    
    func showConfirmRestoreKey() {
        
        // confirm message
        //to import key from restore google drive file.
        let timestamp = CurrentTimeStamp(dateFormatter: "ddMMyyyyHHmmss")
        let timestampShow = CurrentTimeStamp(dateFormatter: "dd-MM-yyyy HH:mm")
        SaveNewKeyfile2Keychain(KeyData: self.dataImport, PasswordFile: self.txtInputPass.text!, tagKeyName: self.txtInsertNameKey.text! + "_" +  timestamp,timestamp: timestampShow)
        //
//        let alertStatusImport = UIAlertController(title: "Restore Successful", message: "", preferredStyle: .alert)
//        alertStatusImport.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
//            //
//            DispatchQueue.main.async {
//                self.dismiss(animated: true, completion: {
//
//                    self.navigationController?.popToRootViewController(animated: true)
//                })
//
//            } //
//            // end
//        }))
        let popUp = PopUpWithImageView(imageName: "checkmark_circle", title: "Restore Successful", okButtonString: "OK") {
            self.navigationController?.popToRootViewController(animated: true)
        }
        popUp.show()
        
//        self.present(alertStatusImport, animated: true)
        
    }// .End func
    
    func showConfirmBackupOrNot(){
        
        if(isRestore){
            showConfirmRestoreKey()
        }else{
            // confirm message
            let timestamp = CurrentTimeStamp(dateFormatter: "ddMMyyyyHHmmss")
            let timestampShow = CurrentTimeStamp(dateFormatter: "dd-MM-yyyy HH:mm")
            
            
            nameKey =  self.txtInsertNameKey.text! + "_" + timestamp
            SaveNewKeyfile2Keychain(KeyData: self.dataImport, PasswordFile: self.txtInputPass.text!, tagKeyName: nameKey, timestamp: timestampShow)
            
//            let alert = UIAlertController(title: "Import Successful", message: "Do you want to backup p12?", preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "Backup", style: .default, handler: { action in
//
//                self.ConnectGoolgeAccount()
//            }))
//
//            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
//                //to import key
//
//                let alertStatusImport = UIAlertController(title: "Import Successful", message: "", preferredStyle: .alert)
//                alertStatusImport.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
//                    //
//                    DispatchQueue.main.async {
//                        self.dismiss(animated: true, completion: {
//
//                            self.navigationController?.popToRootViewController(animated: true)
//                        })
//
//                    } // .End DispatchQueue.main.async
//                }))
//
//                self.present(alertStatusImport, animated: true)
//            }))
//
//            self.present(alert, animated: true)
            
            
            
            let popUp = PopUpTwoButton(imageName: nil, message: "Do you want to backup p12?", acceptButtonString: "Backup", cancelButtonString: "No") {
                
                self.ConnectGoolgeAccount()
            } touchCancel: {
                
                let popUpNoButton = PopUpWithImageView(imageName: "checkmark_circle", title: "Import Successful", okButtonString: "OK") {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                popUpNoButton.show()
            }
            
            popUp.show()
            
        }
        
        
        // .End conform message
    } // .End showConfirmBackupOrNot
}
// MARK: - GIDSignInDelegate
//extension ImportKeyViewController: GIDSignInDelegate {
//
////    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
////
////    }
////    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
////
////    }
//
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if (error == nil) {
//            print("Login True")
//            service.authorizer = user.authentication.fetcherAuthorizer()
//            print("Login Successed!")
//            let storyboard = UIStoryboard(name: "Main", bundle: nil);
//            let vc = storyboard.instantiateViewController(withIdentifier: "BackupViewController") as! BackupViewController;
//            vc.dataImport = self.dataImport
//            vc.name = self.nameKey
//            vc.drive = self.drive
//            DispatchQueue.main.async {
//                //               self.present(vc, animated: true, completion: nil)
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        } else {
//            print("Login Failed")
//            service.authorizer = nil
//            print(user)
//            print(error.localizedDescription)
//            if(error.localizedDescription == "The user canceled the sign-in flow."){
//                self.navigationController?.popViewController(animated: true)
//            }
//
////            if let error = error {
////                //            showAlert (title: "Authentication Error", message: error.localizedDescription)
////                service.authorizer = nil
////                print("Login Failed")
////    //            self.navigationController?.popToRootViewController(animated: true)
////
////            } else {
////                service.authorizer = user.authentication.fetcherAuthorizer()
////                print("Login Successed!")
////                let storyboard = UIStoryboard(name: "Main", bundle: nil);
////                let vc = storyboard.instantiateViewController(withIdentifier: "BackupViewController") as! BackupViewController;
////                vc.dataImport = self.dataImport
////                vc.name = self.nameKey
////                vc.drive = self.drive
////                DispatchQueue.main.async {
////                    //               self.present(vc, animated: true, completion: nil)
////                    self.navigationController?.pushViewController(vc, animated: true)
////                }
////            }
//        }
//
//    }
//
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
//        print("Did disconnect to user")
////        self.navigationController?.popToRootViewController(animated: true)
//    }
//}
//
//// MARK: - GIDSignInUIDelegate
//extension ImportKeyViewController: GIDSignInUIDelegate {}
//
//extension UINavigationBar {
//    open override func sizeThatFits(_ size: CGSize) -> CGSize {
//        return CGSize(width: UIScreen.main.bounds.width, height: 51)
//    }
//}
