//
//  RestoreViewController.swift
//  tedamobilesigning
//
//  Created by Prawit Phiwhom on 3/5/2564 BE.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

class RestoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var MainView: ViewController!
    
    fileprivate let service = GTLRDriveService()
    private var drive: ATGoogleDrive?
    
    @IBOutlet weak var tvEmail: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    private var myArray = [GTLRDrive_File]()
    private var nameKey:String = ""
    private var selectFile :GTLRDrive_File = GTLRDrive_File()
    
    let progressHUD = ProgressHUD(text: "Loading...")
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.title = "Restore"
        myTableView.dataSource = self
        myTableView.delegate = self
        
      
          self.view.addSubview(progressHUD)
        
        GIDSignIn.sharedInstance.signOut()
        //ConnectGoolgeAccount()
        self.navigationItem.backButtonDisplayMode = .minimal

    }
    
    override func viewDidAppear(_ animated: Bool) {
        ConnectGoolgeAccount()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(myArray[indexPath.row])")
        nameKey = myArray[indexPath.row].name!
        selectFile = myArray[indexPath.row]
        
        
        // show confirm restore
        self.showConfirmRestore()
        //download(file: myArray[indexPath.row])
        //download(file:myArray[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
              
              // set the text from the data model
              cell.textLabel?.text = myArray[indexPath.row].name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
//        let date = dateFormatter.date(from: myArray[indexPath.row].createdTime!.stringValue)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateString = dateFormatter.string(from: myArray[indexPath.row].createdTime!.date)
        
        let _ : String = "Something the user entered"
        _ = NSMutableAttributedString(string: "The value is: ")
        
        let boldText  = "Last update: "
        let normalText = dateString
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 11)]
        let attributedString = NSMutableAttributedString(string:normalText)
        let boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
        boldString.append(attributedString)
        cell.detailTextLabel?.attributedText = boldString
        return cell
    }

    
   
    
    func ConnectGoolgeAccount() {
        print("ConnectGoolgeAccount")
        //Google
//        GIDSignIn.sharedInstance()?.signOut()
        //
        //GIDSignIn.sharedInstance.delegate = self
        //GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDriveFile]
        //GIDSignIn.sharedInstance.scopes = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDrive, kGTLRAuthScopeDriveAppdata, kGTLRAuthScopeDriveMetadata, kGTLRAuthScopeDriveScripts]
//        GIDSignIn.sharedInstance().signInSilently()
        
//        let additionalScopes = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDrive, kGTLRAuthScopeDriveAppdata, kGTLRAuthScopeDriveMetadata, kGTLRAuthScopeDriveScripts]
//        GIDSignIn.sharedInstance.addScopes(additionalScopes, presenting: self) { user, error in
//            print("addScopes user : \(user)")
//            print("addScopes error :\(error)")
//            guard error == nil else { return }
//            guard let _ = user else { return }
//        }
        //
        drive = ATGoogleDrive(service)
        
        //Sign to google account
        //GIDSignIn.sharedInstance()?.signIn()
        GIDSignIn.sharedInstance.signIn(with: AppDelegate.signInConfig, presenting: self) { user, error in
            if let _ = error {
                self.service.authorizer = nil
                print("Login Failed")
                print(error?.localizedDescription)
                self.navigationController?.popViewController(animated: true)
            } else {
                //self.service.authorizer = user?.authentication.fetcherAuthorizer()
                print("Login Successed!")
                self.tvEmail.text = user?.profile?.email
                
                let additionalScopes = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDriveAppdata]
                GIDSignIn.sharedInstance.addScopes(additionalScopes, presenting: self) { user, error in
                    guard error == nil else { self.progressHUD.hide(); return }
                    guard let user = user else { self.progressHUD.hide(); return }

                    self.service.authorizer = user.authentication.fetcherAuthorizer()
                    self.getAllfolders()
                }
                
            }
          }
    }
    
    func getAllfolders() {
        progressHUD.show()
       let root = "mimeType = 'application/vnd.google-apps.folder'"
       let query = GTLRDriveQuery_FilesList.query()
       query.pageSize = 100
       query.q = root
       query.fields = "files(id,name,mimeType,modifiedTime,createdTime,fileExtension,size),nextPageToken"
       service.executeQuery(query, completionHandler: {(ticket, files, error) in
           if let filesList : GTLRDrive_FileList = files as? GTLRDrive_FileList {
               if let filesShow : [GTLRDrive_File] = filesList.files {
                   print("files \(filesShow)")
                   for ArrayList in filesShow {
                       let name = ArrayList.name ?? ""
                       let id = ArrayList.identifier ?? ""
//                       print("hello\(name)", id)
                    print("file : \(name), id : \(id)")
                    if(name == "TEDA Sign"){
                        self.getMyFolders(id: id)
                        break
                    }
//                    self.myArray.adding(name)
                   }
               } else {
                    self.progressHUD.hide()
               }
           } else {
                self.progressHUD.hide()
           }
//        self.myTableView.beginUpdates()
//        self.myTableView.insertRows(at: [IndexPath.init(row: self.myArray.count-1, section: 0)], with: .automatic)
//        self.myTableView.endUpdates()
        
       })
     }
    
    func getMyFolders(id:String) {
        
        let root = "'\(id)' in parents and trashed=false"
    
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.q = root
        query.fields = "files(id,name,mimeType,modifiedTime,createdTime,fileExtension,size),nextPageToken"
    
       service.executeQuery(query, completionHandler: {(ticket, files, error) in
        
           if let filesList : GTLRDrive_FileList = files as? GTLRDrive_FileList {
               if let filesShow : [GTLRDrive_File] = filesList.files {
//                   print("files \(filesShow)")
                   for ArrayList in filesShow {
                       let name = ArrayList.name ?? ""
                       let id = ArrayList.identifier ?? ""
//                       print("file \(name)", id)
                    self.myArray.append(ArrayList)
                   }
               }
           }
        self.myTableView.reloadData()
        self.progressHUD.hide()
       })
     }
    
    func download(file: GTLRDrive_File) {
        let url = "https://www.googleapis.com/drive/v3/files/\(file.identifier!)?alt=media"
        let fetcher = service.fetcherService.fetcher(withURLString: url)
        fetcher.beginFetch(completionHandler: { data, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            print("downloaded")
            
            // reading data
            let savedText = String(decoding: data!, as: UTF8.self)
            //let savedText = String(contentsOf: data)
            print("savedText:", savedText)   // "Hello World !!!\n"
            
            //
//            self.MainView.TextAES = savedText
//            self.dismiss(animated: true, completion: nil)
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "ExtractFileToRestoreViewController") as! ExtractFileToRestoreViewController;
           
            vc.TextAES = savedText
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)  {
//               self.present(vc, animated: true, completion: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        })
    }
    
    @IBAction func Cancel(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showConfirmRestore(){
        
        let popUp = PopUpTwoButton(imageName: nil, title: "Restore", message: "Confirm restore file " + nameKey + " ?", acceptButtonString: "CONFIRM", cancelButtonString: "CANCEL") {
            
            self.download(file: self.selectFile)
        } touchCancel: {
            
        }
        
        popUp.show()
//
//
//        let alert = UIAlertController(title: "Restore", message: "Confirm restore file " + nameKey + " ?", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "CONFIRM", style: .default, handler: { action in
//
//            //self.ConnectGoolgeAccount()
//            self.download(file: self.selectFile)
//        }))
//
//        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { action in
//            //to import key
//
//                //
//                DispatchQueue.main.async {
//                    self.dismiss(animated: true, completion: {
//
//                        //
//                    })
//                } // .End DispatchQueue.main.async
//
//        }))
//
//        self.present(alert, animated: true)
        
        // .End conform message
    }
}

//// MARK: - GIDSignInDelegate
//extension RestoreViewController: GIDSignInDelegate {
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if let _ = error {
////            showAlert (title: "Authentication Error", message: error.localizedDescription)
//            service.authorizer = nil
//            print("Login Failed")
//            self.navigationController?.popViewController(animated: true)
//        } else {
//            service.authorizer = user.authentication.fetcherAuthorizer()
//            print("Login Successed!")
//            tvEmail.text = user.profile?.email
//            DispatchQueue.main.async {
////                self.dismiss(animated: true, completion: nil)
//                self.getAllfolders()
//            }
//
//        }
//    }
//
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
//            print("Did disconnect to user")
//
//    }
//}
//// MARK: - GIDSignInUIDelegate
//extension RestoreViewController: GIDSignInUIDelegate {}
