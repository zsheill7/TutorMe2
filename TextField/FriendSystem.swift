/*
 * Copyright (C) 2017, Zoe Sheill.
 * All rights reserved.
 *
 */


import Foundation
import Firebase
import FirebaseAuth
import SCLAlertView

class FriendSystem {
    
    static let system = FriendSystem()
    func displayAlert(_ title: String, message: String) {
        SCLAlertView().showInfo(title, subTitle: message)
        
    }

    // MARK: - Firebase references

    let BASE_REF = FIRDatabase.database().reference()

    let USER_REF = FIRDatabase.database().reference().child("users")
    

    var CURRENT_USER_REF: FIRDatabaseReference {
        let id = FIRAuth.auth()?.currentUser!.uid
        return USER_REF.child("\(id!)")
    }
    

    var CURRENT_USER_FRIENDS_REF: FIRDatabaseReference {
        return CURRENT_USER_REF.child("friends")
    }
    
    /** Gets the current user's active friend requests **/
    var CURRENT_USER_REQUESTS_REF: FIRDatabaseReference {
        return CURRENT_USER_REF.child("requests")
    }
    
    /** The current user's id */
    var CURRENT_USER_ID: String {
        let id = FIRAuth.auth()?.currentUser!.uid
        return id!
    }

    
    /** Gets the current User object for the user id */
    func getCurrentUser(_ completion: @escaping (User) -> Void) {
        CURRENT_USER_REF.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let email = value?["email"] as? String
           // let email = snapshot.childSnapshot(forPath: "email").value as! String
            let id = snapshot.key
            completion(User(snapshot: snapshot))
        })
    }
    /** Gets the User object for the specified user id */
    func getUser(_ userID: String, completion: @escaping (User) -> Void) {
        USER_REF.child(userID).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if let email = snapshot.childSnapshot(forPath: "email").value as? String {
            
                let id = snapshot.key
                completion(User(snapshot: snapshot))
            }
        })
    }
    
    
    
    // MARK: - Account Related

    /**
     Creates a new user account with the specified email and password
     - parameter completion: What to do when the block has finished running. The success variable 
     indicates whether or not the signup was a success
     */
    func createAccount(_ email: String, password: String, name: String, completion: @escaping (_ success: Bool) -> Void) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if (error == nil) {
                // Success
                var userInfo = [String: AnyObject]()
                userInfo = ["email": user!.email! as AnyObject,
                            "password": password as AnyObject,
                            "name": name as AnyObject]
                self.CURRENT_USER_REF.setValue(userInfo)
                completion(true)
            } else {
                // Failure
                self.displayAlert("Unable to Sign Up", message: (error?.localizedDescription)!)
                completion(false)
            }
            
        })
    }
    
    /**
     Logs in an account with the specified email and password
     
     - parameter completion: The success variable
     indicates whether or not the login was a success
     */
    
    func loginAccount(_ email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if (error == nil) {
                // Success
                completion(true)
            } else {
                // Failure
                completion(false)
                print(error)
            }
            
        })
    }
    
    /** Logs out an account */
    func logoutAccount() {
        try! FIRAuth.auth()?.signOut()
    }
    
    
    
    // MARK: - Request System Functions
    
    /** Sends a friend request to the user with the specified id */
    func sendRequestToUser(_ userID: String) {
        USER_REF.child(userID).child("requests").child(CURRENT_USER_ID).setValue(true)
    }
    
    /** Unfriends the user with the specified id */
    func removeFriend(_ userID: String) {
        CURRENT_USER_REF.child("friends").child(userID).removeValue()
        USER_REF.child(userID).child("friends").child(CURRENT_USER_ID).removeValue()
    }
    
    /** Accepts a friend request from the user with the specified id */
    func acceptFriendRequest(_ userID: String) {
       // CURRENT_USER_REF.child("requests").child(userID).removeValue()
        CURRENT_USER_REF.child("friends").child(userID).setValue(true)
        USER_REF.child(userID).child("friends").child(CURRENT_USER_ID).setValue(true)
       // USER_REF.child(userID).child("requests").child(CURRENT_USER_ID).removeValue()
    }
    
    
    
    // MARK: - All users
    /** The list of all users */
    var userList = [User]()
    /** Adds a user observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addUserObserver(_ update: @escaping () -> Void) {
        /*FriendSystem.system.*/USER_REF.observe(FIRDataEventType.value, with: { (snapshot) in
            self.userList.removeAll()
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let value = child.value as? [String: AnyObject]
                //print(value)
                let email = value?["email"] as? String
                let description = value?["description"] as? String
                //let name = value?["name"] as? String
                //let password = value?["password"] as? String
                let isTutor = value?["isTutor"] as? Bool
                
                let userDefaults = UserDefaults.standard
                if let currentUserIsTutor = userDefaults.value(forKey: "isTutor") as? Bool {
                    if email != nil {
                        print("email:" + email!)
                    }
                    //print("name:" + name!)
                    // let email = snapshot.childSnapshot(forPath: "email").value as! String
                    
                    if email != FIRAuth.auth()?.currentUser?.email! && description != nil{
                        if (currentUserIsTutor == true && isTutor == false) ||
                            (currentUserIsTutor == false && isTutor == true) {
                            //print(User(snapshot: child))
                            print("here in if email")
                            self.userList.append(User(snapshot: child))
                        }
                    }
                }
                else {
                    // no highscore exists
                }
                
                
            }
            update()
        })
    }
    /** Removes the user observer. This should be done when leaving the view that uses the observer. */
    func removeUserObserver() {
        USER_REF.removeAllObservers()
    }
    
    
    
    // MARK: - All friends
    /** The list of all friends of the current user. */
    var friendList = [User]()
  
    func addFriendObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_FRIENDS_REF.observe(FIRDataEventType.value, with: { (snapshot) in
            self.friendList.removeAll()
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    self.friendList.append(user)
                    update()
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    /** Removes the friend observer. This should be done when leaving the view that uses the observer. */
    func removeFriendObserver() {
        CURRENT_USER_FRIENDS_REF.removeAllObservers()
    }
    
    
    
    // MARK: - All requests
    /** The list of all friend requests the current user has. */
    var requestList = [User]()
    /** Adds a friend request observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addRequestObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_REQUESTS_REF.observe(FIRDataEventType.value, with: { (snapshot) in
            self.requestList.removeAll()
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    self.requestList.append(user)
                    update()
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    /** Removes the friend request observer. This should be done when leaving the view that uses the observer. */
    func removeRequestObserver() {
        CURRENT_USER_REQUESTS_REF.removeAllObservers()
    }
    
}



