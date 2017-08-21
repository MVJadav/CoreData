//
//  AddUserVC.swift
//  CoreDataDemo
//
//  Created by MVJadav on 17/08/17.
//  Copyright © 2017 MVJadav. All rights reserved.
//

import UIKit
import CoreData


@objc protocol AddUserDelegate:class {
    @objc optional func didFinishAddUser()
}

class AddUserVC: UIViewController {

    var delegate:AddUserDelegate?
    
    @IBOutlet weak var IBemail                  : UITextField!
    @IBOutlet weak var IBimage                  : UITextField!
    @IBOutlet var IBbarbtnBack                  : UIBarButtonItem!
    @IBOutlet var IBbarbtnAddUser               : UIBarButtonItem!
    @IBOutlet var IBbarbtnDeleteUser            : UIBarButtonItem!
    
    var isEditable      : Bool = false
    var objUser         : User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setView()
        if self.isEditable {
            self.setData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

//MARK: - IBAction Methods
extension AddUserVC {
    
    //btnBack Click
    @IBAction func barbtnBackClick(sender: AnyObject) {
        _ =  self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnClickAddUser(_ sender: AnyObject) {
        
        if isEditable {
            self.updateUser(email: self.IBemail.text!, image_url: self.IBimage.text!, user: self.objUser)
        }else {
            self.storeUser(email: self.IBemail.text!, image_url: IBimage.text!)
        }
    }
    
    @IBAction func btnClickDeleteUser(_ sender: AnyObject) {
        self.deleteUser(user: self.objUser)
    }
}

//MARK: - Other Methods
extension AddUserVC {
    
    func setView() {
        self.setNavigation()

    }
    func setNavigation(isCompleted : Bool? = false) {
        
        self.navigationItem.leftBarButtonItem       = IBbarbtnBack
        if isEditable {
            self.navigationItem.rightBarButtonItems     = [IBbarbtnAddUser, IBbarbtnDeleteUser]
            self.navigationItem.titleView = Common().setNavigationBarTitle(title: "User", subtitle: "Edit User")
        }else {
            self.navigationItem.rightBarButtonItems     = [IBbarbtnAddUser]
            self.navigationItem.titleView = Common().setNavigationBarTitle(title: "User", subtitle: "New User")
        }
        
    }
    //MARK: - Alert Function for testing only.
    func AlertMessage(msg:String){
        
        let alertController = UIAlertController(title: "Action", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setData() {
        
        if let email = self.objUser.email {
            self.IBemail.text = email
        }
        if let image = self.objUser.image_url {
            self.IBimage.text = image
        }
    }
}

//MARK: - Service Call
extension AddUserVC {
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

//
    func storeUser (email: String, image_url: String) {
        let context = getContext()
        
        //retrieve the entity that we just created
        let entity =  NSEntityDescription.entity(forEntityName: "User", in: context)
        
        let user = NSManagedObject(entity: entity!, insertInto: context)
        
        //set the entity values
        user.setValue(email, forKey: "email")
        user.setValue(image_url, forKey: "image_url")
        
        //save the object
        do {
            try context.save()
            print("saved!")
            self.delegate?.didFinishAddUser!()
            _ =  self.navigationController?.popViewController(animated: true)
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }
    
    func updateUser (email:String, image_url:String,user : User) {
        
        let context = getContext()
        //let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            //let array_users = try getContext().fetch(fetchRequest)
            //let user = array_users[0]
            
            user.setValue(email, forKey: "email")
            user.setValue(image_url, forKey: "image_url")
            
            print("\(user.value(forKey: "email"))")
            
            //save the context
            do {
                try context.save()
                print("saved!")
                self.delegate?.didFinishAddUser!()
                _ =  self.navigationController?.popViewController(animated: true)
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    //MARK: - Delete User
    func deleteUser (user : User) {
        
        let context = getContext()
        do {
            context.delete(user)
            do {
                try context.save()
                print("saved!")
                self.delegate?.didFinishAddUser!()
                _ =  self.navigationController?.popViewController(animated: true)
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
            }
        } catch {
            print("Error with request: \(error)")
        }
    }

    
}

