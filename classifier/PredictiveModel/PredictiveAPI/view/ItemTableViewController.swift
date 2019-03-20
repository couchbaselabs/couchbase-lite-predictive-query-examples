//
//  ItemTableViewController.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 1/11/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import Foundation
import UIKit

class ItemTableViewController:UITableViewController, UserPresentingViewProtocol {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    fileprivate var userRecord:UserRecord?
    fileprivate var matchingRecords:[UserRecord]?
    
    lazy var userPresenter:UserPresenter = UserPresenter()
    
    fileprivate var nameTextEntry:UITextView?
    fileprivate var userImageView: UIImageView!
    fileprivate var imageUpdated:Bool = false

    fileprivate let kSegueId = "ItemsViewSegue"
    
    let  baselineProfileSections:Int = 3
    
    enum Section {
        case image
        case basic
        case extended
        
        var index:Int {
            switch self {
            case .image:
                return 0
            case .basic:
                return 1
            case .extended:
                return 2
            }
        }
        
        var numRows:Int {
            switch self {
            case .image:
                return 1
            case .basic:
                return 1
            case .extended:
                return 0 // This can grow dynamically
            }
        }
        
        var rowHeight:CGFloat {
            switch self {
            case .image:
                return 200.0
            case .basic:
                return 50.0
            case .extended:
                return 0 // This can grow dynamically
            }
        }
    }
    
    enum BasicRows {
        case name
        
        var index:Int {
            switch self {
            case .name:
                return 0
            }
        }
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Your Item", comment: "")
        self.initializeTable()
        self.registerCells()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.userPresenter.attachPresentingView(self)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.userPresenter.detachPresentingView(self)
    }
    
    private func initializeTable() {
        //    self.tableView.backgroundColor = UIColor.darkGray
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.sectionHeaderHeight = 10.0
        self.tableView.sectionFooterHeight = 10.0
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
    }
    
    private func registerCells() {
        let basicInfoNib = UINib(nibName: "CustomTextEntryTableViewCell", bundle: Bundle.main)
        self.tableView?.register(basicInfoNib, forCellReuseIdentifier: "BasicInfoCell")
        
        let imageNib = UINib(nibName: "CustomImageEntryTableViewCell", bundle: Bundle.main)
        self.tableView?.register(imageNib, forCellReuseIdentifier: "ImageCell")
        
    }
    
    deinit {
        self.userPresenter.detachPresentingView(self)
        
    }
    
    
}

// MARK: IBActions
extension ItemTableViewController {
    @IBAction func onDoneTapped(_ sender: UIBarButtonItem) {
       userRecord = UserRecord.init()
        
        //   let image = userImageView.image else {return}
        userRecord?.tag = self.nameTextEntry?.text

        if let imageVal = self.userImageView?.image, let imageData = imageVal.pngData()  {
            userRecord?.photo = imageData
        }
        
        self.userPresenter.lookupClosestMatchingRecord(userRecord)
        
    }
    
    @IBAction func onAddItemTapped(_ sender: UIBarButtonItem) {
        userRecord = UserRecord.init()
        
        //   let image = userImageView.image else {return}
        userRecord?.tag = self.nameTextEntry?.text
        
        if let imageVal = self.userImageView?.image, let imageData = imageVal.pngData()  {
            userRecord?.photo = imageData
        }
        
        self.userPresenter.addRecordToDatabase(userRecord)
        
    }
    

}

//MARK:UITableViewDataSource
extension ItemTableViewController{
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.basic.index:
            return Section.basic.numRows
        case Section.extended.index:
            return Section.extended.numRows
        case Section.image.index:
            return Section.image.numRows
        default:
            return 0
        }
    }
    
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print(#function)
        
        switch indexPath.section {
        // Profile Image
        case Section.image.index:
            guard let cell = tableView.dequeueReusableCell( withIdentifier: "ImageCell") as? CustomImageEntryTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.selectionStyle = .none
            userImageView = cell.imageEntryView
            if let imageData = self.userRecord?.photo{
                cell.imageBlob  = UIImage.init(data: imageData)
            }
            else {
                cell.imageBlob  = UIImage.init(imageLiteralResourceName: "default-user-thumbnail")
            }
            
            return cell
            
        // Basic Info
        case Section.basic.index :
            switch indexPath.row {
            case BasicRows.name.index :
                guard let cell = tableView.dequeueReusableCell( withIdentifier: "BasicInfoCell") as? CustomTextEntryTableViewCell else {
                    return UITableViewCell()
                }
                cell.textEntryName.text = NSLocalizedString("Name:", comment: "")
                cell.selectionStyle = .none
                
                nameTextEntry = cell.textEntryValue
                nameTextEntry?.isEditable = true
                nameTextEntry?.delegate = self
                
                cell.selectionStyle = .none
                
                if let name = self.userRecord?.tag as? String {
                    nameTextEntry?.text = name
                }
                else {
                   nameTextEntry?.text = "Person" // some random text
                }
                
                return cell
            
            default:
                return UITableViewCell()
            }
            
        // future
        case Section.extended.index :
            return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "DefaultCell")
        default:
            return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "DefaultCell")
            
        }
        
        
    }
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        switch indexPath.section {
        // Profile Image
        case Section.image.index:
            return Section.image.rowHeight
            
        // Basic Info
        case Section.basic.index:
            return Section.basic.rowHeight
            
        // Extended
        case Section.extended.index:
            return Section.extended.rowHeight
        default:
            return 0
            
        }
        
        return UITableView.automaticDimension
    }
    
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        var numExtn = 0
        // Future extensions
        if let record = self.userRecord {
            if let extensions = record.extended  {
                numExtn = extensions.count
            }
        }
        return self.baselineProfileSections + numExtn
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        // Profile Image
        case Section.image.index:
            return
            
        // Basic Info
        case Section.basic.index:
            switch indexPath.row {
            case BasicRows.name.index :
                return
            default:
                return
                
            }
            
        // Extended
        case Section.extended.index:
            return
        default:
            return
            
        }
    }
}



// MARK : CustomImageEntryTableViewCellProtocol
extension ItemTableViewController:CustomImageEntryTableViewCellProtocol {
    func onUploadImage() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.modalPresentationStyle = .popover
        
        let albumAction = UIAlertAction(title: NSLocalizedString("Select From Photo Album", comment: ""), style: .default) { action in
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = false
            imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary;
            
            imagePickerController.modalPresentationStyle = .overCurrentContext
            
            self.present(imagePickerController, animated: true, completion: nil)
            
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let cameraAction = UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .default) { [unowned self] action in
                
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.allowsEditing = false
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera;
                imagePickerController.cameraDevice = UIImagePickerController.CameraDevice.front;
                
                imagePickerController.modalPresentationStyle = .overCurrentContext
                
                self.present(imagePickerController, animated: true, completion: nil)
                
            }
            alert.addAction(cameraAction)
            
        }
        alert.addAction(albumAction)
        
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        present(alert, animated: true, completion: nil)
        
    }
}


extension ItemTableViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imageKey = UIImagePickerController.InfoKey.originalImage
        if let image = info[imageKey] as? UIImage {
            self.userImageView.image = image
            self.imageUpdated = true
            self.doneButton.isEnabled = true
            self.nameTextEntry?.text = "person"
            picker.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
   
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
// MARK : UserPresentingViewProtocol
extension ItemTableViewController {
    func updateUIWithMatchingRecords(_ records: [UserRecord]?, error: Error?) {
        switch error {
            case nil:
            self.matchingRecords = records
            self.performSegue(withIdentifier: kSegueId, sender: nil)
            print("Top Matching record is \(records?.first)")
            // For now, display the top matching result
//            self.title = "Match in Database"
//            if let record = records?.first {
//                self.userRecord = record
//                self.tableView.reloadData()
//            }
//            else {
//                self.showAlertWithTitle(NSLocalizedString("No Match!", comment: ""), message: (error?.localizedDescription) ?? "No matching user record")
//            }
            default:
               self.showAlertWithTitle(NSLocalizedString("Error!", comment: ""), message: (error?.localizedDescription) ?? "No matching user record")
        }
    }
    
}

// MARK: UITextViewDelegate
extension ItemTableViewController:UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            switch textView {
            case self.nameTextEntry!: break
            default:
                textView.resignFirstResponder()
                
            }
        }
        let length = (textView.text?.characters.count)! - range.length + text.characters.count
        let nameTextEntryLength = (textView == self.nameTextEntry) ? length : self.nameTextEntry?.text?.characters.count ?? 0
        self.doneButton.isEnabled = imageUpdated || nameTextEntryLength > 0 
        
        return true
    }
    
}
// MARK: Segue
 extension ItemTableViewController  {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueId {
            if let destNavController = segue.destination as? UINavigationController, let destController = destNavController.topViewController as? ItemsCollectionViewController, let matches = self.matchingRecords{
               destController.items  = matches
            }
        }
        
    }
}
