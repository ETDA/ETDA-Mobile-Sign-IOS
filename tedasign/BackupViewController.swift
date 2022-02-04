//
//  BackupKeyViewController.swift
//  tedamobilesigning
//
//  Created by Prawit Phiwhom on 5/4/2564 BE.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

class BackupViewController: UIViewController, UITextFieldDelegate {
    
    //

    var drive: ATGoogleDrive?
    var dataImport:NSData!
    var name:String!
 

    let folderName = "TEDA Sign"
    
    @IBOutlet weak var eyeButton: UIButton!

    
    @IBOutlet weak var createPassContainerView: UIView!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var txtCreatePass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Set Password"
        self.navigationItem.backButtonDisplayMode = .minimal
        self.eyeButton.setImage(UIImage(named: "iconEye.png"), for: .normal)
        self.navigationItem.hidesBackButton = true
        let searchBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(popToRoot))
        self.navigationItem.leftBarButtonItem = searchBarButtonItem

    }
    @objc func popToRoot(sender:UIBarButtonItem){
        print("popToRoot")
        self.navigationController?.popToRootViewController(animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        txtCreatePass.becomeFirstResponder()
    }
    
    @IBAction func touchShowOrHidePasswordButton(_ sender: Any) {
        print("savedText:", txtCreatePass.isSecureTextEntry)
        if(txtCreatePass.isSecureTextEntry){
            self.eyeButton.setImage(UIImage(named: "iconEyeDis.png"), for: .normal)
        } else {
            self.eyeButton.setImage(UIImage(named: "iconEye.png"), for: .normal)
        }
        txtCreatePass.isSecureTextEntry.toggle()
    }
    
    
    @IBAction func Backup(_ sender: Any) {
        if(txtCreatePass.text?.count ?? 0<8){
            alertInput()
            return
        }
        self.txtCreatePass.resignFirstResponder()
        BackuptoGoogleDrive()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtCreatePass {
            createPassContainerView.borderColor = UIColor(rgb: 0x0047B1)
            passwordLabel.textColor = .black
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtCreatePass {
            createPassContainerView.borderColor = UIColor(rgb: 0x000000, alpha: 0.6)
            passwordLabel.textColor = UIColor(rgb: 0x000000, alpha: 0.4)
        }

        return true
    }

    
    func alertInput(){
//        let alert = UIAlertController(title: "Warning", message: "รหัสผ่านอย่างน้อย 8 ตัว", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
//
//
//        }))
//        self.present(alert, animated: true)

        let popUp = PopUpWithImageView(imageName: "x_circle", title: "รหัสผ่านอย่างน้อย 8 ตัว", okButtonString: "OK")
        popUp.show()
    }
    
    func BackuptoGoogleDrive() {
        
        //Backup file to google drive.
        do {
            //1. Encrypt file
//            let encryptBase64 = AESEncrypt(data: dataImport as Data, KeyPasswordAES: KeyPasswordAES)
            
            let cryptLib = CryptLib()
            let str = dataImport.base64EncodedString()
            let encryptBase64 = cryptLib.encryptPlainTextRandomIV(withPlainText: str, key: txtCreatePass.text)
            
            // get the documents folder url
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentDirectory.appendingPathComponent(name + "_backup.txt")
                let text = encryptBase64
                try text?.write(to: fileURL, atomically: false, encoding: .utf8)
                
                // any posterior code goes here
                // reading from disk
//                    let savedText = try String(contentsOf: fileURL)
//                    print("savedText:", savedText)   // "Hello World !!!\n"
                
                //2. Send File To Google Drive
                drive?.uploadFile(folderName, filePath: fileURL.path, MIMEType: "text/plain") { (fileID, error) in
                    print("backup successful - Upload file ID: \(fileID); Error: \(error?.localizedDescription)")
                }
            }
            
            //3.Import Key
//            SaveNewKeyfile2Keychain(KeyData: dataImport, PasswordFile: KeyPassword, tagKeyName: Keyname)
            
            //Message descritpion
//            let alert = UIAlertController(title: "Import Successful", message: "", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
//                //Close page
//                DispatchQueue.main.async {
////                    self.dismiss(animated: true, completion: nil)
//                    self.navigationController?.popToRootViewController(animated: true)
//                }
//            }))
//
//            //Alert Message
//            DispatchQueue.main.async {
//                self.present(alert, animated: true, completion: nil)
//            }
            
            let popUp = PopUpWithImageView(imageName: "checkmark_circle", title: "Import Successful", okButtonString: "OK") {
                self.navigationController?.popToRootViewController(animated: true)
            }
            popUp.show()
            
        } catch {
            print("error:", error)
//            
//            //Message descritpion error
//            let alert = UIAlertController(title: "Error!", message: " \(error)", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
//
//                //Close page
//                DispatchQueue.main.async {
//                    self.dismiss(animated: true, completion: nil)
//                }
//            }))
//
//            //Alert Message
//            self.present(alert, animated: true, completion: nil)
            
            let popUp = PopUpWithImageView(imageName: "x_circle", title: "\(error)", okButtonString: "OK") {
                self.navigationController?.popToRootViewController(animated: true)
            }
            popUp.show()
            
            return
        }
        
    }
    
    
}

