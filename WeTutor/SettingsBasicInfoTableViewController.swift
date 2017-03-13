//
//  TutorSignUpViewController.swift
//  TextField
//
//  Created by Zoe on 12/21/16.
//  Copyright © 2017 Zoe Sheill. All rights reserved.
//

import UIKit
//import Eureka
import Material
//import ChameleonFramework
import SCLAlertView
import Firebase
import FirebaseDatabase
import CoreLocation
import NVActivityIndicatorView

private enum MenuSection {
    case all(content: AllContent)
    case menuView(content: MenuViewContent)
    case menuController(content: MenuControllerContent)
    
    fileprivate enum AllContent: Int { case standard, segmentedControl, infinite }
    fileprivate enum MenuViewContent: Int { case underline, roundRect }
    fileprivate enum MenuControllerContent: Int { case standard }
    
    

    
    init?(indexPath: IndexPath) {
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
        case (0, let row):
            guard let content = AllContent(rawValue: row) else { return nil }
            self = .all(content: content)
        case (1, let row):
            guard let content = MenuViewContent(rawValue: row) else { return nil }
            self = .menuView(content: content)
        case (2, let row):
            guard let content = MenuControllerContent(rawValue: row) else { return nil }
            self = .menuController(content: content)
        default: return nil
        }
    }
    
    var options: PagingMenuControllerCustomizable {
        let options: PagingMenuControllerCustomizable
        options = PagingMenuOptions1()
        return options
        
    }
}




class SettingsBasicInfoTableViewController : FormViewController {
    var ref: FIRDatabaseReference!
    var currentUser: User?
    
    func displayAlert(_ title: String, message: String) {
        SCLAlertView().showInfo(title, subTitle: message)
        
    }
    
    let cols = 4
    let rows = 8
    var cellWidth = 2
    var cellHeight = 2
    
    struct Static {
        static let nameTag = "name"
        static let passwordTag = "password"
        static let lastNameTag = "lastName"
        static let zipcodeTag = "zipcode"
        static let emailTag = "email"
        static let schoolTag = "school"
        static let phoneTag = "phone"
        static let enabled = "enabled"
        static let check = "check"
        static let segmented = "segmented"
        static let gender = "gender"
        static let birthday = "birthday"
        static let subjects = "subjects"
        static let button = "button"
        static let stepper = "stepper"
        static let slider = "slider"
        static let textView = "textview"
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("currentUser?.phone as AnyObject?")
        print(currentUser?.phone as AnyObject?)
        //initializeForm()
        
        self.loadForm()
        cellWidth = Int(self.view.frame.width / CGFloat(cols))
        cellHeight = Int(self.view.frame.height / CGFloat(rows))
        
        self.view.addBlueBackground("mixed2")
        
    }
    /*override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(white: 1, alpha: 0.7)
    }*/
    
    // MARK: Actions
    
    func submit(_: UIBarButtonItem!) {
        
        let message = self.form.formValues().description
        
        let alertController = UIAlertController(title: "Form output", message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "OK", style: .cancel) { (action) in
        }
        
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Private interface
    
    func goBackToSettings() {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "settingsNC") as! UINavigationController
        self.present(controller, animated: true, completion: nil)
    }
    
    fileprivate func loadForm() {
        
        let form = FormDescriptor(title: "Example Form")
        
        var row = FormRowDescriptor(tag: Static.emailTag, type: .email, title: "Email")
        
        let section1 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)

        
        row = FormRowDescriptor(tag: Static.zipcodeTag, type: .text, title: "Zip Code")
        row.configuration.cell.appearance = ["textField.placeholder" : "e.g. 98040" as AnyObject, "textField.textAlignment" : NSTextAlignment.right.rawValue as AnyObject]
        row.value = currentUser?.address as AnyObject?
        section1.rows.append(row)
        
        let section2 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        
        row = FormRowDescriptor(tag: Static.schoolTag, type: .url, title: "School Name")
        row.configuration.cell.appearance = ["textField.placeholder" : "e.g. Mercer Island High School" as AnyObject, "textField.textAlignment" : NSTextAlignment.right.rawValue as AnyObject]
        print(currentUser?.school as AnyObject? ?? "")
        row.value = currentUser?.school as AnyObject?
        print("row.value")
        print(row.value)
        section2.rows.append(row)
        
        row = FormRowDescriptor(tag: Static.phoneTag, type: .phone, title: "Phone")
        row.configuration.cell.appearance = ["textField.placeholder" : "e.g. 13069242633" as AnyObject, "textField.textAlignment" : NSTextAlignment.right.rawValue as AnyObject]
        row.value = currentUser?.phone as AnyObject?
        section2.rows.append(row)
        
        let section3 = FormSectionDescriptor(headerTitle: "", footerTitle: nil)
        
        row = FormRowDescriptor(tag: Static.gender, type: .picker, title: "Gender")
        row.configuration.cell.showsInputToolbar = true
        row.configuration.selection.options = (["F", "M", "U"] as [String]) as [AnyObject]
        row.configuration.selection.optionTitleClosure = { value in
            guard let option = value as? String else { return "" }
            switch option {
            case "F":
                return "Female"
            case "M":
                return "Male"
            case "U":
                return "Other/I'd rather not say"
            default:
                return ""
            }
        }
        
        row.value = "F" as AnyObject
        
        section3.rows.append(row)
        
        /*row = FormRowDescriptor(tag: Static.birthday, type: .date, title: "Birthday")
        row.configuration.cell.showsInputToolbar = true*/
        
        row = FormRowDescriptor(tag: Static.subjects, type: .picker, title: "Grade")
        row.configuration.selection.options = (["Kindergarten", "1st grade", "2nd grade", "3rd grade", "4th grade", "5th grade", "6th grade", "7th grade", "8th grade", "9th grade", "10th grade", "11th grade", "12th grade", "College"] as [String]) as [AnyObject]
        row.configuration.selection.allowsMultipleSelection = true
        row.configuration.selection.optionTitleClosure = { value in
            guard let option = value as? String else { return "" }
            return option
            /*switch option {
            case "Kindergarten":
                return "Kindergarten"
            case "1st grade":
                return "1st grade"
            case "2nd grade":
                return "2nd grade"
            case "3rd grade":
                return "3rd grade"
            case "4th grade":
                return "4th grade"
            case "5th grade":
                return "5th grade"
            case "6th grade":
                return "6th grade"
            case "7th grade":
                return "7th grade"
            case "8th grade":
                return "8th grade"
            case "9th grade":
                return "9th grade"
            case "10th grade":
                return "10th grade"
            case "11th grade":
                return "11th grade"
            case "12th grade":
                return "12th grade"
            case 13:
                return "College"*/
                
                
            
            
        }
        //row.value = "Kindergarten" as AnyObject
        row.value = currentUser?.grade as AnyObject?
        section3.rows.append(row)
        
        row = FormRowDescriptor(tag: Static.subjects, type: .picker, title: "Preferred Subject")
        row.configuration.selection.options = (["No Preference", "Math", "Reading or writing", "Science"] as [String]) as [AnyObject]
        row.configuration.selection.allowsMultipleSelection = true
        row.configuration.selection.optionTitleClosure = { value in
            guard let option = value as? String else { return "" }
            return option
            /*switch option {
            case 0:
                return "No Preference"
            case 1:
                return "Math"
            case 2:
                return "Reading or writing"
            case 3:
                return "Science"
            */
                
           
        }
        //row.value = 0 as AnyObject
        row.value = currentUser?.preferredSubjects[0] as AnyObject?
        
        section3.rows.append(row)

        let section4 = FormSectionDescriptor(headerTitle: "Description", footerTitle: nil)
        row = FormRowDescriptor(tag: Static.textView, type: .multilineText, title: "About Me")
       // row.cell.contentView.tintColor = UIColor(white: 1, alpha: 0.5)
        
        row.configuration.cell.appearance = ["tintColor" : UIColor.red]
        row.value = currentUser?.description as AnyObject?
        section4.rows.append(row)
        
        let section5 = FormSectionDescriptor(headerTitle: " ", footerTitle: nil)
        
        //row.configuration.cell.appearance = ["textField.placeholder" : "This will be a part of your profile. Tell us about yourself. What are your extracurriculars?  Do you have experience with working with children?" as AnyObject, "textField.textAlignment" : NSTextAlignment.right.rawValue as AnyObject]
        row = FormRowDescriptor(tag: Static.button, type: .button, title: "Continue")
        row.configuration.button.didSelectClosure = { _ in
            self.view.endEditing(true)
           // self.form.validateForm()
           if let zipcode = self.form.sections[0].rows[0].value,
            let schoolName = self.form.sections[1].rows[0].value,
            let phone    = self.form.sections[1].rows[1].value,
            let gender    = self.form.sections[2].rows[0].value,
            let grade    = self.form.sections[2].rows[1].value,
            let preferredSubject = self.form.sections[2].rows[2].value,
            let description = self.form.sections[3].rows[0].value {
            
                self.ref = FIRDatabase.database().reference()
            
            
                let userDefaults = UserDefaults.standard
                print(schoolName)
                print(grade)
                print(description)
            
            let user = FIRAuth.auth()?.currentUser
            
            let userID = FIRAuth.auth()?.currentUser?.uid
            self.ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                print("got snapshot")
                
                let value = snapshot.value as? NSDictionary
                print(value?["name"] as? String ?? "")
                print(value?["password"] as? String ?? "")
                print(value?["email"] as? String ?? "")
                print(value?["isTutor"] as? Bool)
                if let name = value?["name"] as? String,
                let password = value?["password"] as? String,
                    let email = value?["email"] as? String,
                    let isTutor = value?["isTutor"] as? Bool{
                        
                        
                   /* if let email = userDefaults.value(forKey: "email"),
                        let password = userDefaults.value(forKey: "password"),
                        let name = userDefaults.value(forKey: "name"),
                        let user = FIRAuth.auth()?.currentUser {*/
                    let x = Int(self.view.center.x)
                    let y = Int(self.view.center.y)
                    let frame = CGRect(x: x, y: y, width: self.cellWidth, height: self.cellHeight)
                    
                    let activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                                        type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.lineScale.rawValue) )
                    let animationTypeLabel = UILabel(frame: frame)
                    
                    animationTypeLabel.text = "Loading..."
                    animationTypeLabel.sizeToFit()
                    animationTypeLabel.textColor = UIColor.white
                    animationTypeLabel.frame.origin.x += 5
                    animationTypeLabel.frame.origin.y += CGFloat(self.cellHeight) - animationTypeLabel.frame.size.height
                    
                    activityIndicatorView.padding = 20
                    self.view.addSubview(activityIndicatorView)
                    self.view.addSubview(animationTypeLabel)
                    activityIndicatorView.startAnimating()

                    
                    self.ref.child("users/\(userID!)/zipcode").setValue(zipcode)
                    self.ref.child("users/\(userID!)/schoolName").setValue(schoolName)
                    self.ref.child("users/\(userID!)/phone").setValue(phone)
                    self.ref.child("users/\(userID!)/gender").setValue(gender)
                    self.ref.child("users/\(userID!)/grade").setValue(grade)
                    self.ref.child("users/\(userID!)/preferredSubject").setValue(preferredSubject)
                    self.ref.child("users/\(userID!)/description").setValue(description)
                    /*self.ref.child("users/\(userID!)/").setValue()
                    self.ref.child("users/\(userID!)/").setValue()
                    self.ref.child("users/\(userID!)/").setValue()*/
                    
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(zipcode as! String) { placemarks, error in
                        if error != nil {
                            print(error?.localizedDescription ?? "")
                        } else {
                            for placemark in placemarks! {
                                let location = placemark.location
                                let latitude = location?.coordinate.latitude
                                let longitude = location?.coordinate.longitude
                                self.ref.child("users/\(userID!)/latitude").setValue(latitude)
                                self.ref.child("users/\(userID!)/longitude").setValue(longitude)
                            }
                        }
                    }
                    activityIndicatorView.stopAnimating()
                    //self.performSegue(withIdentifier: "toSecondVC", sender: self)
                    self.displayAlert("Success!", message: "Your settings have been updated")
                    self.goBackToSettings()
                    
                //self.ref.child("users").child(userID!).observeSingleEvent
            } //if let zipcode = self.form.sections[0].rows[0].value,
                //let schoolName = self.form.sections[1].rows[0].value,

            
            // ...
        }) { (error) in
            self.displayAlert("Error", message: error.localizedDescription)
        }
    
            
            
            
            
           } else {
                self.displayAlert("Error", message: "Please fill out every section.")
            }
            
            
        }
        section5.rows.append(row)
        
        form.sections = [section1, section2, section3, section4, section5]
        
        self.form = form
    }
}


