//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by MVJadav on 17/08/17.
//  Copyright © 2017 MVJadav. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

//    var array_users :User = [User]

    var array_users : [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.storeUser(email: "mehul@mail.com", image_url: "abcd.jpg")
        self.getUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension ViewController {
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
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
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }
    func getUsers () {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            //go get the results
            
            //let array_users = try getContext().fetch(fetchRequest)
            self.array_users = try getContext().fetch(fetchRequest)
            
            //I like to check the size of the returned results!
            print ("num of users = \(array_users.count)")
            
            //array_users[0].value(forKey: "email")
            
            //You need to convert to NSManagedObject to use 'for' loops
            for user in array_users as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                print("\(user.value(forKey: "email"))")
            }
            
        } catch {
            print("Error with request: \(error)")
        }
    }
}
