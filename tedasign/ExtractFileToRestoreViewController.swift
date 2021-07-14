//
//  ExtractFileToRestoreViewController.swift
//  tedamobilesigning
//
//  Created by Prawit Phiwhom on 6/5/2564 BE.
//

import UIKit

class ExtractFileToRestoreViewController: UIViewController, UITextFieldDelegate {

    var MainView:ViewController!
    var TextAES : String = ""
    @IBOutlet weak var eyeButton: UIButton!

    
//    @IBOutlet weak var lblProgressPersen: UILabel!
//    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var passwordForExtractFileContainerView: UIView!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var txtPasswordForExtractFile: UITextField!
//    @IBOutlet weak var btnCancel: UIBarButtonItem!
//    @IBOutlet weak var btnNext: UIBarButtonItem!
    
    var isRed = false
    var progressBarTimer: Timer!
    var isRunning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eyeButton.setImage(UIImage(named: "iconEye.png"), for: .normal)
        txtPasswordForExtractFile.delegate = self
//        lblProgressPersen.isHidden = true
//        progressView.isHidden = true
//        self.navigationItem.hidesBackButton = true
//        self.navigationItem.backButtonDisplayMode = .minimal

//        let newBackButton = UIBarButtonItem(title: "<", style:.done , target: self, action: Selector(("popToRoot:")))
//        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtPasswordForExtractFile {
            passwordForExtractFileContainerView.borderColor = UIColor(rgb: 0x0047B1)
            passwordLabel.textColor = .black
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtPasswordForExtractFile {
            passwordForExtractFileContainerView.borderColor = UIColor(rgb: 0x000000, alpha: 0.6)
            passwordLabel.textColor = UIColor(rgb: 0x000000, alpha: 0.4)
        }

        return true
    }
    
//    func ProgressView() {
//
//        //
//        progressView.progress = 0.0
//
//        //
//        if(isRunning){
//            progressBarTimer.invalidate()
//            //btn.setTitle("Start", for: .normal)
//        }
//        else{
//            //btn.setTitle("Stop", for: .normal)
//            progressView.progress = 0.0
//            self.progressBarTimer = Timer.scheduledTimer(timeInterval: 0.09, target: self, selector: #selector(ExtractFileToRestoreViewController.updateProgressView), userInfo: nil, repeats: true)
//        if(isRed){
//            progressView.progressTintColor = UIColor.blue
//            progressView.progressViewStyle = .default
//        }
//        else{
//            progressView.progressTintColor = UIColor.blue
//            progressView.progressViewStyle = .bar
//
//        }
//        isRed = !isRed
//        }
//        isRunning = !isRunning
//    }
    @IBAction func touchShowOrHidePasswordButton(_ sender: Any) {
        if(txtPasswordForExtractFile.isSecureTextEntry){
            self.eyeButton.setImage(UIImage(named: "iconEyeDis.png"), for: .normal)
        } else {
            self.eyeButton.setImage(UIImage(named: "iconEye.png"), for: .normal)
        }
        
        self.txtPasswordForExtractFile.isSecureTextEntry.toggle()
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        self.txtPasswordForExtractFile.resignFirstResponder()
        if (txtPasswordForExtractFile.text == "" ){
//            let alert = UIAlertController(title: "Warning!", message: "Please input Password", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true)
            let popUp = PopUpWithImageView(imageName: "checkmark_circle", title: "Please input Password", okButtonString: "OK")
            popUp.show()
            return
        }
        
        //
//        txtPasswordForExtractFile.isEnabled = false
//        btnCancel.isEnabled = false
//        btnNext.isEnabled = false
        //ProgressView()
        ExtractFile(password: txtPasswordForExtractFile.text!)
        
    }
    
//    @objc func updateProgressView(){
//
//        lblProgressPersen.isHidden = false
//        progressView.isHidden = false
//
//        progressView.progress += 0.01
//        progressView.setProgress(progressView.progress, animated: true)
//        self.lblProgressPersen.text = "\(Int(self.progressView.progress * 100))" + " % . . ."
//
//        if(progressView.progress == 1.0)
//        {
//            ExtractFile(password: txtPasswordForExtractFile.text!)
//            progressBarTimer.invalidate()
//            isRunning = false
//        }
//    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }

//    @IBAction func Cancel(_ sender: Any) {
//        DispatchQueue.main.async {
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
    
//    @IBAction func Next(_ sender: Any) {
//
//        //Check Input
//        if (txtPasswordForExtractFile.text == "" ){
//            let alert = UIAlertController(title: "Warning!", message: "กรุณาระบุ Password", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            txtPasswordForExtractFile.becomeFirstResponder()
//            self.present(alert, animated: true)
//            return
//        }
//
//        //
//        txtPasswordForExtractFile.isEnabled = false
////        btnCancel.isEnabled = false
////        btnNext.isEnabled = false
//        //ProgressView()
//        ExtractFile(password: txtPasswordForExtractFile.text!)
//    }
    
    func ExtractFile(password: String) {
        
        let cryptLib = CryptLib()
        let data = cryptLib.decryptCipherTextRandomIV(withCipherText: TextAES, key: password)
        if(data==nil){
//            let alert = UIAlertController(title: "Warning!", message: "Wrong password", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true)
            let popUp = PopUpWithImageView(imageName: "checkmark_circle", title: "Wrong password", okButtonString: "OK")
            popUp.show()
            return
        }
        let dataKey = NSData(base64Encoded: data!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        if(dataKey==nil){
//            let alert = UIAlertController(title: "Warning!", message: "Wrong password", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true)
            let popUp = PopUpWithImageView(imageName: "checkmark_circle", title: "Wrong password", okButtonString: "OK")
            popUp.show()
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "ImportKeyViewController") as! ImportKeyViewController;
//        vc.modalPresentationStyle = .fullScreen
        vc.isRestore = true
        vc.dataImport = dataKey
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
//           self.present(vc, animated: true, completion: nil)
          
        }
        
    }
    
}
