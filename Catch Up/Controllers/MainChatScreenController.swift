//
//  MainChatScreenController.swift
//  Catch Up
//
//  Created by CZ Ltd on 5/16/19.
//  Copyright © 2019 CZ Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos
import JSQMessagesViewController
import IQAudioRecorderController
import IDMPhotoBrowser
import Firebase
import FirebaseMessaging
import FirebaseDatabase
import JSQMessagesViewController
import FirebaseStorage
import SwiftKeychainWrapper



//import CameraManager




class MainChatScreenController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate,IQAudioRecorderViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
  
  
//    func messagesCollectionViewCellDidTapAvatar(_ cell: JSQMessagesCollectionViewCell!) {
//
//    }
//
//    func messagesCollectionViewCellDidTapMessageBubble(_ cell: JSQMessagesCollectionViewCell!) {
//
//    }
//
//    func messagesCollectionViewCellDidTap(_ cell: JSQMessagesCollectionViewCell!, atPosition position: CGPoint) {
//
//    }
//
//    func messagesCollectionViewCell(_ cell: JSQMessagesCollectionViewCell!, didPerformAction action: Selector!, withSender sender: Any!) {
//
//    }
//

    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        
    }
    
  
let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var recipient: String!
    var messageId: String!
    
    
    var messages = [Message]()
    
    var message: Message!

    var currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    
    @IBOutlet weak var chatTableView: UITableView!
    
    
   // navigation outlets
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navProfileImage: UIImageView!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var navigationView: GradientView!
    @IBOutlet weak var threadBackupView: UIView!
    @IBOutlet weak var threadMainImageView: UIImageView!
    @IBOutlet weak var bottomBarView: UIView!
    
    
    // bottom bar outlets
    
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var typeMessageTextField: UITextField!
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
//    var cameraManager : CameraManager!
    
    
    @IBOutlet var recordView: UIView!
    @IBOutlet var openKeyboard: UIButton!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var recordDeleteButton: UIButton!
    @IBOutlet var recordAudioButton: UIButton!
    @IBOutlet var sendRecordButton: UIButton!
  
    var audioRecorder:AVAudioRecorder!
    var meterTimer:Timer!
    var isRecording = false
    var isAudioRecordingGranted: Bool!
    
   
    
//    var picker:UIImagePickerController?=UIImagePickerController()
    
    @IBOutlet var cameraOVerlayView: UIView!
    
    // listeners
    
//    var typingListener: ListenerRegistration?
//    var updatedChatListener: ListenerRegistration?
//    var newChatListener: ListenerRegistration?
    
    // initializers for chat
    
    let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    var typingCounter = 0
//    var messages: [JSQMessage] = []
    var objectMessages: [NSDictionary] = []
    var loadedMessages: [NSDictionary] = []
    var allPictureMessages: [String] = []
    var initialLoadComplete = false
    var jsqAvatarDictionary: NSMutableDictionary?
    var avatarImageDictionary: NSMutableDictionary?
    var showAvatars = true
    var firstLoad: Bool?
    var keyboardSize: CGRect?
    var openKeyboardForFirstTime: Bool = true
    
    var dummyBoolArray = [true,false,false,true,true,false,true,false]
    
    var dummyMessageArray = ["heysdhfishfisdhfisdhfosdhfpsdhfojdshfjpsdhfkjsdhfjdskhfjsdhfsdjhfskdjhfdskjhfdsjfhsdjhfdsjkhfdskjhfdskjfhdsjkhfdsjhfdskjhfdskjfhdskjhfdskjfhdkjsfhdskjhfdksj hey hey hey hey hey hey hey hey","hey hey hey hey hey hey hey hey","how are you","im fine","how is going","good","ok","take care"]
    
    
    @IBOutlet var btnRecordOrSend: UIButton!
    
    
//    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
//
//    var incomingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
//
//     let composeVC = JSQMessagesViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
//        chatTableView.estimatedRowHeight = 300.0
//        chatTableView.rowHeight = UITableView.automaticDimension

        if messageId != "" && messageId != nil {
            
            loadData()
            
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil)


        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

        view.addGestureRecognizer(tap)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            
            self.moveToBottom()
        }
        
        typeMessageTextField.delegate = self
        
        // set corner radius for view's rounded corner
        
        threadBackupView.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
        threadMainImageView.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
        chatTableView.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
        recordView.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
        bottomBarView.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
        navProfileImage.layer.cornerRadius = navProfileImage.frame.height/2
        
        if let StatusbarView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
           
            StatusbarView.backgroundColor = UIColor(red: 15/255, green: 110/255, blue: 255/255, alpha: 1)
          
            StatusbarView.setGradientBackground(view: StatusbarView)
        }
        
        bottomBarView.layer.masksToBounds = false
      
        recordView.layer.masksToBounds = false
        
//        picker?.delegate = self
        
        
        // button targetss
        
        openKeyboard.addTarget(self, action: #selector(openKeyboard(sender:)), for: .touchUpInside)
        
        recordDeleteButton.addTarget(self, action: #selector(deleteRecord(sender:)), for: .touchUpInside)
        
        recordAudioButton.addTarget(self, action: #selector(audioRecord(sender:)), for: .touchUpInside)
        
        sendRecordButton.addTarget(self, action: #selector(sendRecord(sender:)), for: .touchUpInside)
        
//        cameraManager = CameraManager()
        
//        cameraManager.shouldFlipFrontCameraImage = true
        
        checkPermission()
        
        recordView.isHidden = true
        
        displayMessageInterface()
        
    } //viewdidload
    
    
    @objc func keyboardWillShow(notify: NSNotification) {
        
        if openKeyboardForFirstTime == true {
            
            keyboardSize = (notify.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue

            openKeyboardForFirstTime = false
        }
        
            if self.view.frame.origin.y == 0 {
                
                if let Keyboard = keyboardSize {
                    
                     self.view.frame.origin.y -= Keyboard.height
                }
               
            }
    }
    

    
    @objc func keyboardWillHide(notify: NSNotification) {
        
//        if let keyboardSize = (notify.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
        
//        }
        
        if self.view.frame.origin.y != 0 {
            
            if let Keyboard = keyboardSize {
                
                self.view.frame.origin.y += Keyboard.height
            }
            
        }
    }
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        recordView.isHidden = true
        
        typeMessageTextField.resignFirstResponder()
    }
    
    @IBAction func didTappedBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTappedEmoji(_ sender: Any) {
        
        
    }
    
    func displayMessageInterface() {
       
//        composeVC.automaticallyScrollsToMostRecentMessage = true
//        composeVC.collectionView.delegate = self
//        composeVC.send
        
        
//        composeVC.messageComposeDelegate = self
//
//        // Configure the fields of the interface.
//        composeVC.recipients = ["3142026521"]
//        composeVC.body = "I love Swift!"
        
        // Present the view controller modally.
//        if MFMessageComposeViewController.canSendText() {
//            self.present(composeVC, animated: true, completion: nil)
//        } else {
//            print("Can't send messages.")
//        }
    }
    
    @IBAction func didTappedAttchments(_ sender: Any) {
        
        openGallery()
        
        // for image
        
//        let myPickerController = UIImagePickerController()
        
//        myPickerController.delegate = self;
//        myPickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
//        addChild(myPickerController)
//        threadMainImageView.addSubview(myPickerController.view)
        
//        myPickerController.view.frame = threadMainImageView.bounds
//
//        myPickerController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
//        let pickerr = ImagePickerController()
//        pickerr.delegate = self
//        present(pickerr, animated: true, completion: nil)
        
        
        
//            self.present(pickerr, animated: true, completion: nil)
//
//        myPickerController.didMove(toParent: self)
    }
    
    @IBAction func didTappedCamera(_ sender: Any) {
        
//        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
//
//            picker?.cameraOverlayView = cameraOVerlayView
//
//            picker?.showsCameraControls = false
        
            
//            cameraManager.addPreviewLayerToView(self.view)
//            cameraManager.shouldFlipFrontCameraImage = true
//            picker!.sourceType = UIImagePickerController.SourceType.camera
//            self .present(picker!, animated: true, completion: nil)
//        }
        
        let sb = UIStoryboard(name: "Chat", bundle: nil)
        
        let vc = sb.instantiateViewController(withIdentifier: "CutomCameraViewController")
        
        self.navigationController?.present(vc, animated: true, completion: nil)

    }
    
    @IBAction func recordOrSendButton(_ sender: Any) {
        
         recordView.isHidden = false
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    //chat table view
    
    func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
//            return messages.count
        
        return dummyMessageArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let message = messages[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Message") as? mainChatScreenTableViewCell {
            
            cell.sentMessageLbl.roundCorners(corners: [.topLeft,.bottomLeft,.bottomRight], radius: 5.0)
            
            cell.recievedMessageLbl.roundCorners(corners: [.topRight,.bottomLeft,.bottomRight], radius: 5.0)
            
            cell.recievedMessageLbl.sizeToFit()

            
//            cell.configCell(message: message)
            
            if dummyBoolArray[indexPath.row] == true {
                
                cell.recievedMessageView.isHidden = false
                cell.sentMessageView.isHidden = true
                
                cell.recievedMessageLbl.text = dummyMessageArray[indexPath.row]
                cell.receivedTimeLabel.text = "10:26 AM"
                
            }else {
                
                cell.recievedMessageView.isHidden = true
                cell.sentMessageView.isHidden = false
                
                cell.sentMessageLbl.text = dummyMessageArray[indexPath.row]
                cell.sentTimeLabel.text = "10:26 AM"
            }
            
            return cell
            
        } else {
            
            return mainChatScreenTableViewCell()
        }
        
    }
    
    func loadData() {
        
        Database.database().reference().child("messages").child(messageId).observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                self.messages.removeAll()
                
                for data in snapshot {
                    
                    if let postDict = data.value as? Dictionary<String, AnyObject> {
                        
                        let key = data.key
                        
                        let post = Message(messageKey: key, postData: postDict)
                        
                        self.messages.append(post)
                    }
                }
            }
            
            self.chatTableView.reloadData()
        })
        
    }//loadData
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        typeMessageTextField.resignFirstResponder()//
        
        
        return true
    }
    
    
    func messageSend(){
        
        if (typeMessageTextField.text != nil && typeMessageTextField.text != "") {
            
            if messageId == nil {
                
                let post: Dictionary<String, AnyObject> = [
                    "message": typeMessageTextField.text as AnyObject,
                    "sender": recipient as AnyObject
                ]
                
                let message: Dictionary<String, AnyObject> = [
                    "lastmessage": typeMessageTextField.text as AnyObject,
                    "recipient": recipient as AnyObject
                ]
                
                let recipientMessage: Dictionary<String, AnyObject> = [
                    "lastmessage": typeMessageTextField.text as AnyObject,
                    "recipient": currentUser as AnyObject
                ]
                
                messageId = Database.database().reference().child("messages").childByAutoId().key
                
                let firebaseMessage = Database.database().reference().child("messages").child(messageId).childByAutoId()
                
                firebaseMessage.setValue(post)
                
                let recipentMessage = Database.database().reference().child("users").child(recipient).child("messages").child(messageId)
                
                recipentMessage.setValue(recipientMessage)
                
                let userMessage = Database.database().reference().child("users").child(currentUser!).child("messages").child(messageId)
                
                userMessage.setValue(message)
                
                loadData()
            } else if messageId != "" {
                
                let post: Dictionary<String, AnyObject> = [
                    "message": typeMessageTextField.text as AnyObject,
                    "sender": recipient as AnyObject
                ]
                
                let message: Dictionary<String, AnyObject> = [
                    "lastmessage": typeMessageTextField.text as AnyObject,
                    "recipient": recipient as AnyObject
                ]
                
                let recipientMessage: Dictionary<String, AnyObject> = [
                    "lastmessage": typeMessageTextField.text as AnyObject,
                    "recipient": currentUser as AnyObject
                ]
                
                let firebaseMessage = Database.database().reference().child("messages").child(messageId).childByAutoId()
                
                firebaseMessage.setValue(post)
                
                let recipentMessage = Database.database().reference().child("users").child(recipient).child("messages").child(messageId)
                
                recipentMessage.setValue(recipientMessage)
                
                let userMessage = Database.database().reference().child("users").child(currentUser!).child("messages").child(messageId)
                
                userMessage.setValue(message)
                
                loadData()
            }
            
            typeMessageTextField.text = ""
        }
        
//        moveToBottom()

    }
    
    func moveToBottom() {
        
        if messages.count > 0  {
            
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            
            chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    
}//class

//extension MainChatScreenController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//
//
//
//    }
//
//}

extension MainChatScreenController: AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    
    func checkPermission() {
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSession.RecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
        
    }
    
    @objc func deleteRecord(sender: UIButton) {
        
        if audioRecorder != nil {
            
            audioRecorder.stop()
            audioRecorder = nil
            meterTimer.invalidate()
            
        }
        
        isRecording = false
        timerLabel.text = "00:00"
        
    }
    
    @objc func audioRecord(sender: UIButton) {
        
        if(isRecording)
        {
            finishAudioRecording(success: true)
            recordAudioButton.setImage(UIImage(named: "Record"), for: .normal)
//            play_btn_ref.isEnabled = true
            isRecording = false
        }
        else
        {
            setup_recorder()
            isRecording = true
            audioRecorder.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            recordAudioButton.setImage(UIImage(named: "stop_Record"), for: .normal)
//            play_btn_ref.isEnabled = false
            
        }
        
    }
    
    @objc func sendRecord(sender: UIButton) {
        
      
        
    }
    
    @objc func openKeyboard(sender: UIButton) {
        
        recordView.isHidden = true
        
        typeMessageTextField.becomeFirstResponder()
        
    }
    
    
    @objc func updateAudioMeter(timer: Timer)
    {
        if audioRecorder.isRecording
        {
//            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d",min,sec)
            print("audio timer",totalTimeString)
            timerLabel.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    func finishAudioRecording(success: Bool)
    {
        if success
        {
            audioRecorder.stop()
            audioRecorder = nil
            meterTimer.invalidate()
            print("recorded successfully.")
        }
        else{
            print("error while finishing audio record")
        }
    }
    
    func setup_recorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
//                try session.setCategory(AVAudioSession.Category.playAndRecord, with: .mixWithOthers)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: AVAudioSession.CategoryOptions.mixWithOthers)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            }
            catch let error {
                print("catched some error during recording")
            }
        }else {
            print("please enable audio access for catch app")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag
        {
            finishAudioRecording(success: false)
        }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        
    }
}

extension MainChatScreenController {
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileUrl() -> URL
    {
        let filename = "myRecording.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
}

//extension MainChatScreenController: ImagePickerControllerDelegate {
//    
//    func imagePickerController(_ picker: ImagePickerController, shouldLaunchCameraWithAuthorization status: AVAuthorizationStatus) -> Bool {
//        return true
//    }
//    
//    func imagePickerController(_ picker: ImagePickerController, didFinishPickingImageAssets assets: [PHAsset]) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: ImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//}

//extension MainChatScreenController : UITableViewDataSource,UITableViewDelegate {
//
//
//
//}

extension MainChatScreenController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        typeMessageTextField.becomeFirstResponder()
            
        btnRecordOrSend.setImage(UIImage(named: "btn_send2"), for: .normal)
            
    
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
         typeMessageTextField.resignFirstResponder()
        
        if typeMessageTextField.text!.count > 0 {
            
            btnRecordOrSend.setImage(UIImage(named: "btn_send2"), for: .normal)
            
        }else {
            
            btnRecordOrSend.setImage(UIImage(named: "btn voice"), for: .normal)
        }
        
    }
    
}



