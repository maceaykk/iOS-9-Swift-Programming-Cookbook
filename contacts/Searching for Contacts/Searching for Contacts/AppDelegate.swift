//
//  AppDelegate.swift
//  Searching for Contacts
//
//  Created by Vandad on 7/9/15.
//  Copyright © 2015 Pixolity. All rights reserved.
//

import UIKit
import SharedCode
import Contacts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var store = CNContactStore()
  
  //finds anybody named john
  func example1(){
    
    NSOperationQueue().addOperationWithBlock{[unowned store] in
      
      let predicate = CNContact.predicateForContactsMatchingName("john")
      
      let toFetch = [CNContactGivenNameKey, CNContactFamilyNameKey]
      
      do{
        let contacts = try store.unifiedContactsMatchingPredicate(
          predicate, keysToFetch: toFetch)
        
        for contact in contacts{
          print(contact.givenName)
          print(contact.familyName)
          print(contact.identifier)
        }
        
      } catch let err{
        print(err)
      }
      
    }
    
  }
  
  //another way of finding anybody named john with CNContactFetchRequest
  func example2(){
    
    NSOperationQueue().addOperationWithBlock{[unowned store] in
      let toFetch = [CNContactGivenNameKey, CNContactFamilyNameKey]
      let request = CNContactFetchRequest(keysToFetch: toFetch)
      request.predicate = CNContact.predicateForContactsMatchingName("john")
      
      do{
        try store.enumerateContactsWithFetchRequest(request) {
          contact, stop in
          print(contact.givenName)
          print(contact.familyName)
          print(contact.identifier)
        }
      } catch let err{
        print(err)
      }
      
    }
    
  }
  
  //fetch all contacts with name similar to Foo and then once found, fetch
  //their profile picture
  func example3(){
    
    NSOperationQueue().addOperationWithBlock{[unowned store] in
      var toFetch = [CNContactImageDataAvailableKey]
      let predicate = CNContact.predicateForContactsMatchingName("foo")
      do{
        let contacts = try store.unifiedContactsMatchingPredicate(predicate,
          keysToFetch: toFetch)
        
        for contact in contacts{
          guard contact.imageDataAvailable else{
            continue
          }
          
          //have we fetched image data?
          if contact.isKeyAvailable(CNContactImageDataKey){
            print(contact.givenName)
            print(contact.identifier)
            print(UIImage(data: contact.imageData!))
          }
          else {
            toFetch += [CNContactImageDataKey, CNContactGivenNameKey]
            do{
              let contact = try store.unifiedContactWithIdentifier(
                contact.identifier, keysToFetch: toFetch)
              print(contact.givenName)
              print(UIImage(data: contact.imageData!))
              print(contact.identifier)
            } catch let err{
              print(err)
            }
          }
        }
        
      } catch let err{
        print(err)
      }
    }
    
  }
  
  //fetch a contact with the given identifier
  func example4(){
    
    NSOperationQueue().addOperationWithBlock{[unowned store] in
      let id = "AECF6A0E-6BCB-4A46-834F-1D8374E6FE0A:ABPerson"
      let toFetch = [CNContactGivenNameKey, CNContactFamilyNameKey]
      
      do{
        
        let contact = try store.unifiedContactWithIdentifier(id,
          keysToFetch: toFetch)
        
        print(contact.givenName)
        print(contact.familyName)
        print(contact.identifier)
        
      } catch let err{
        print(err)
      }
    }
    
  }
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    ContactAuthorizer.authorizeContactsWithCompletionHandler{succeeded in
      
      if succeeded{
        self.example1()
        self.example2()
        self.example3()
        self.example4()
      } else {
        print("Not handled")
      }
      
    }
    
    return true
  }
}

