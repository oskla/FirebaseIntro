//
//  DatabaseCollection.swift
//  FirebaseIntro
//
//  Created by Oskar Larsson on 2022-10-14.
//

import Foundation
import Firebase

class DatabaseConnection: ObservableObject {
    
    
   private var db = Firestore.firestore()
    
   @Published var userLoggedIn = false
   @Published var currentUser: User?
   @Published var userDocument: UserDocument?
    
    var userDocumentListener: ListenerRegistration?
    
    
    init() {
        
        do {
         try Auth.auth().signOut()
        } catch {
            print("hej")
        }
        
        Auth.auth().addStateDidChangeListener {
            (auth, user) in
            
            if let user = user {
                // Vi är inloggade
                self.userLoggedIn = true
                self.currentUser = user
                self.listenToDb()
                
                
            } else {
                // Vi är utloggade
                self.userLoggedIn = false
                self.currentUser = nil
                self.stopListeningToDb()
            }
            
        }
    }
    
    func stopListeningToDb() {
        if let userDocument = userDocument {
            userDocumentListener?.remove()
        }
    }
    
    func listenToDb() {
        
        if let currentUser = currentUser {
            
            userDocumentListener = self.db.collection("userData").document(currentUser.uid).addSnapshotListener {
                snapshot, error in
                
                if let error = error {
                    print("Error occured \(error)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    return
                }
             
                let result = Result {
                    try snapshot.data(as: UserDocument.self)
                }
                
                switch result {
                case .success(let userData):
                    self.userDocument = userData
                case .failure(let failure):
                    print("Something went wrong. Error: \(failure)")
                }
            }
            
        }
        
    }
    
    // db.collection("userData").document(currentUser.uid)
    
    // updateData <---> Vi vill uppdatera värdet av ett fält,
    // och vi skriver en dictionary vilket fältnamn samt det nya värdet för fältet.
    
    // I det här fallet vill vi inte ge den ett helt nytt värde,
    // utan vi vill lägga till (appenda) ett element, till vår array
    
    // I det nya värdet skriver vi FieldValue.arrayUnion för att tydliggöra att vi vill lägga på och inte ersätta arrayen. Då har vi en array [] där vi lägger inte alla nya element som vi vill lägga in.
    
    // i vårat fall har vi en custom object (JournalEntry), och därför måste vi använda oss utav Firestore.Encoder().encode som kan avläsa vår cutom object till data som kan lagras i Firebase
    
    func addEntryToDb(entry: JournalEntry) {
        
        if let currentUser = currentUser {
            
            do {
                _ = try db.collection("userData").document(currentUser.uid).updateData(["entries": FieldValue.arrayUnion([Firestore.Encoder().encode(entry)])])
            } catch {
                print("askglj")
                
            }
            
        }
        
    }
    
    func LoginUser(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) {
            AuthDataResult, error in
            
           // AuthDataResult?.user.uid
            
            if let error = error {
                print("Error logging in  \(error)")
            }
            
        }
                           
        
    }
    
    func RegisterUser(email: String, password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) {
            authDataResult, error in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let authDataResult = authDataResult {
                
                let newUserDocument = UserDocument(id: authDataResult.user.uid, entries: [])
                
                
                do {
                            // Creating new document in database
                    _ = try self.db.collection("userData").document(authDataResult.user.uid).setData(from: newUserDocument)
                } catch {
                    print("error")
                }
                
            }
            
        }
        
    }
    
    
//    func addItemToStore(item: Item) {
//        do {
//            _ = try db.collection("test").addDocument(from: item)
//        } catch {
//            print("Error saving data")
//        }
//    }
//
//    func listenToStore() {
//        db.collection("test").addSnapshotListener {
//            snapshot, error in
//
//            guard let snapshot = snapshot else {
//                return
//            }
//
//
//            if let error = error {
//                print("Error occurred \(error)")
//                return
//            }
//
//            items.removeAll()
//
//            for document in snapshot.documents {
//
//                let result = Result {
//                    try document.data(as: Item.self)
//                }
//
//                switch result {
//                case .success(let item):
//                    print(item)
//                    items.append(item)
//                case .failure(let error):
//                    print("Error retrieving following document: \(error)")
//                }
//            }
//        }
//    }
//
//
    
}

