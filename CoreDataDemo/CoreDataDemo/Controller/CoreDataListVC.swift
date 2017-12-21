//
//  CoreDataListVC.swift
//  CoreDataDemo
//
//  Created by MVJadav on 17/08/17.
//  Copyright © 2017 MVJadav. All rights reserved.
//

/*
https://medium.com/@shawnbierman/how-to-add-core-data-to-an-existing-xcode-8-and-swift-3-project-508781b3e1c4
 http://veersuthar.com/blogs/2017/01/04/update-and-delete-in-core-data-in-ios10-swift-3/
 http://veersuthar.com/blogs/2017/01/01/how-to-use-core-data-in-ios-10-swift-3/
*/

import UIKit
import CoreData


class CoreDataListVC: UIViewController {

    @IBOutlet var IBbarbtnAdd               : UIBarButtonItem!
    @IBOutlet weak var IBuserTbl            : UITableView!
    @IBOutlet var IBbtnBarSearch            : UIBarButtonItem!
    
//MARK: - Variable Declaration
    
    var array_users                         : [User] = []
    lazy var searchBarCategory              = UISearchBar(frame: CGRect.zero)
    var deleteUser                          : User = User()
    var SearchText                          : String? = ""
    var refreshControl                      : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUsers()
        self.setView()
        
        // Initialize Refresh Control
        self.refreshControl                 = UIRefreshControl()
        self.refreshControl.tintColor       = UIColor.white //AppColor.AppTheme_Primary
        refreshControl?.backgroundColor     = UIColor.purple
        self.self.refreshControl.addTarget(self, action: #selector(CoreDataListVC.pullToRefresh(sender:)), for: UIControlEvents.valueChanged)
        self.IBuserTbl.insertSubview(self.refreshControl, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - UITableView Delegate & DataSource Methods.
extension CoreDataListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if( self.array_users.count > 0 ){
            return self.array_users.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell:UserListVCCell? = tableView.dequeueReusableCell(withIdentifier: "UserListVCCell") as? UserListVCCell
        if (cell == nil) {
            let nib: NSArray = Bundle.main.loadNibNamed("UserListVCCell", owner: self, options: nil)! as NSArray
            cell = nib.object(at: 0) as? UserListVCCell
        }
        cell?.selectionStyle = .none
        if let email = array_users[indexPath.row].value(forKey: "email") {
          cell?.IBname.text = email as? String
        }
        if let email = array_users[indexPath.row].value(forKey: "image_url") {
            cell?.IBlblNumber.text = email as? String
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objAddUserVC                = AddUserVC(nibName: "AddUserVC", bundle: nil)
        objAddUserVC.objUser            = self.array_users[indexPath.row]
        objAddUserVC.isEditable         = true
        objAddUserVC.delegate           = self
        self.navigationController?.pushViewController(objAddUserVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // change delete button color.
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // action two
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            //print("Delete tapped")
        })
        deleteAction.backgroundColor = UIColor.purple
        return [deleteAction]
    }
    // delete button click.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            self.deleteUser = self.array_users[indexPath.row]
            let alert_Delete = SCLAlertView()
            alert_Delete.appearance.showCloseButton = false
            alert_Delete.addButton("Delete", target: self, selector: #selector(self.alertDeleteUser))
            alert_Delete.addButton("Cancel", target: self, selector: #selector(self.alertDeleteCancel))
            alert_Delete.showWarning("Warning", subTitle: "Are you sure you want to delete this User ?")
        }
    }

//MARK: - User Delete and Edit method.
    func alertDeleteUser() {
        self.deleteUser(user: self.deleteUser)
    }
    func alertDeleteCancel() { }
}

//MARK: IBAction Method
extension CoreDataListVC {
    
    @IBAction func btnClickedAddUser(_ sender: Any) {
        
        let objAddUserVC                    = AddUserVC(nibName: "AddUserVC", bundle: nil)
        objAddUserVC.delegate               = self
        self.navigationController?.pushViewController(objAddUserVC, animated: true)
    }
    
    @IBAction func btnClickedSearch(_ sender: Any) {
        self.setNavigation(isSearch: true)
    }
}

//MARK: - Other Methods
extension CoreDataListVC {
    
    func setView() {
        setNavigation()
        self.navigationController?.navigationBar.isTranslucent = false
        self.IBuserTbl.tableFooterView = UIView()
    }
    
    func setNavigation(isSearch : Bool = false) {
        
        if(isSearch){
            self.searchBarCategory.endEditing(true)
            self.searchBarCategory.becomeFirstResponder()
            self.navigationItem.leftBarButtonItem       = nil
            self.navigationItem.rightBarButtonItems     = nil
            self.navigationItem.setHidesBackButton(true, animated: true)
            
            searchBarCategory.placeholder   = "Search User"
            searchBarCategory.delegate      = self
            self.navigationItem.titleView   = searchBarCategory
            _ = Common().setSearchBarBackgroundColor(serachBar: self.searchBarCategory, BGcolor: UIColor.white)
            searchBarCategory.tintColor     = UIColor.white
        }else {
            self.navigationController!.navigationBar.barTintColor           = UIColor.purple
            self.navigationItem.rightBarButtonItems = [IBbarbtnAdd, IBbtnBarSearch]
            
            if (self.SearchText?.isEmptyField)! {
                self.navigationItem.titleView = Common().setNavigationBarTitle(title: "User List", subtitle: "\(self.array_users.count) Items")
            }else {
                self.navigationItem.titleView = Common().setNavigationBarTitle(title: "\(self.SearchText!)", subtitle: "\(self.array_users.count) Items")
            }
        }
    }

    func pullToRefresh(sender:AnyObject) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let title: String = "Last update: \(formatter.string(from: Date()))"
        let attrsDictionary: [AnyHashable: Any] = [ NSForegroundColorAttributeName : UIColor.white ]
        let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary as? [String : Any] ?? [String : Any]())
        refreshControl?.attributedTitle = attributedTitle
        
        self.SearchText = ""
        self.getUsers()
        self.setNavigation()
        
        refreshControl?.endRefreshing()
    }
    
    //MARK: - Alert Function for testing only.
    func AlertMessage(msg:String){
        
        let alertController = UIAlertController(title: "Action", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

//MARK: - SearchBar Method
extension CoreDataListVC : UISearchBarDelegate {
    func searchText(searchText: String, isSearch : Bool=false) {
        
        if !isSearch {
            self.searchBarCategory.text = ""
        }
        self.SearchText          = searchText
        //Service Call here
        if (self.SearchText?.isEmptyField)! {
            self.getUsers()
        }else {
            self.searchUser(sreSearch: self.SearchText!)
        }
        self.setNavigation(isSearch: isSearch)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.text!.isEmpty || searchBar.text! == " "{
            //tblPostList.isHidden = true
        }
        self.searchBarCategory.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBarCategory.showsCancelButton = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText(searchText: searchText, isSearch : true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.searchBarCategory.endEditing(true)
        self.searchText(searchText: self.searchBarCategory.text!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.SearchText = ""
        self.searchBarCategory.endEditing(true)
        self.getUsers()
        self.setNavigation()
    }
}

//MARK: - Service Call
extension CoreDataListVC {
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
//MARK: - Search User
    func searchUser(sreSearch : String) {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        let predicate = NSPredicate(format: "email contains[c] %@", sreSearch)
        fetchRequest.predicate = predicate
        
        do {
            self.array_users = try getContext().fetch(fetchRequest)
            //print ("num of users = \(array_users.count)")
            self.setNavigation()
            
        } catch {
            print("Error with request: \(error)")
        }
        self.IBuserTbl.reloadData()
        
    }
    
//MARK: - Get user User
    func getUsers() {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            //go get the results
            self.array_users = try getContext().fetch(fetchRequest)
            
            //I like to check the size of the returned results!
            //print ("num of users = \(array_users.count)")
            
            //You need to convert to NSManagedObject to use 'for' loops
            /*for user in array_users as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                print("\(user.value(forKey: "email"))")
            }*/
        } catch {
            print("Error with request: \(error)")
        }
        self.IBuserTbl.reloadData()
    }

//MARK: - Delete User
    func deleteUser (user : User) {
        
        let context = getContext()
        do {
            context.delete(user)
            do {
                try context.save()
                print("saved!")
                self.getUsers()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
            }
        } catch {
            print("Error with request: \(error)")
        }
    }
}


//MARK: Add User Delegate Method
extension CoreDataListVC : AddUserDelegate {
    func didFinishAddUser() {
        self.SearchText = ""
        self.getUsers()
        self.setNavigation()
    }
}
