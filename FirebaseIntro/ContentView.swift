//
//  ContentView.swift
//  FirebaseIntro
//
//  Created by Oskar Larsson on 2022-10-12.
//

import SwiftUI
import Firebase
struct ContentView: View {
    
   @StateObject var dbConnection = DatabaseConnection()
    
    
    var body: some View {
        
        if dbConnection.userLoggedIn {
            MainPage(dbConnection: dbConnection)
        } else {
            NavigationView {
                LoginPage(dbConnection: dbConnection)
            }
        }
        
    }
}

struct MainPage: View {
    @ObservedObject var dbConnection: DatabaseConnection
    @State var showPopup = false
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                
                if let userDocument = dbConnection.userDocument {
                    List() {
                        
                        ForEach(userDocument.entries) {
                            entry in
                            
                            Text(entry.title)
                            
                        }
                        
                    }
                }
               
                Button(action: {
                    showPopup = true
                }, label: {
                    Text("Add entry").padding()
                })
        }
            if showPopup {
                PopupView(dbConnection: dbConnection, showPopup: $showPopup)
            }
        }
    }
}

struct PopupView: View {
    
    @ObservedObject var dbConnection: DatabaseConnection
    @Binding var showPopup: Bool
    @State var title = ""
    @State var description = ""
    
    
    var body: some View {
        
        VStack(spacing: 20) {
            Spacer()
            Text("Add entry").font(.title).bold()
            
            VStack(alignment: .leading) {
                
                Text("Ange titel")
                TextField("", text: $title).textFieldStyle(.roundedBorder).foregroundColor(.black)
                Text("Ange beskrivning")
                TextEditor(text: $description).cornerRadius(5).foregroundColor(.black)
            }.padding()
            
            Button(action: {
                
                if title == "" || description == "" {
                    return
                }
                
                dbConnection.addEntryToDb(entry: JournalEntry(title: title, description: description, date: Date()))
                
                showPopup = false
                
                
            }, label: {
                
                Text("Save").bold()
                
            }).padding().background(.white).foregroundColor(.brown).cornerRadius(7)
            
            Button(action: {
                
                showPopup = false
                
            }, label: {
                
                Text("Cancel")
                
            })
            
            Spacer()
            
            
            
        }.frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.6, alignment: .center)
        
            .background(.brown)
        
            .foregroundColor(.white)
        
            .cornerRadius(10)
        
            .shadow(radius: 10)
        
            .transition(.scale)
        
    }
    
}

struct RegisterPage : View {
    @ObservedObject var dbConnection: DatabaseConnection
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    
    var body: some View {
        
        VStack {
            Text("Register account").font(.title)
            
            VStack(alignment: .leading) {
                Text("Email")
                TextField("", text: $email).textFieldStyle(.roundedBorder)
                
                Text("Password")
                SecureField("", text: $password).textFieldStyle(.roundedBorder)
                
                Text("Confirm password")
                SecureField("", text: $confirmPassword).textFieldStyle(.roundedBorder)
            }.padding().padding()
            
            Button(action: {
                if email != "" && password != "" && password == confirmPassword {
                    dbConnection.RegisterUser(email: email, password: password)
                }
            }, label: {
                Text("Register").padding().background(.gray).foregroundColor(.white).cornerRadius(7)
            })
        }
    }
    
}

struct LoginPage: View {
    
    @ObservedObject var dbConnection: DatabaseConnection
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        
        VStack {
            Text("Please log in or register").font(.title)
            VStack(alignment: .leading) {
                Text("Email")
                TextField("", text: $email).textFieldStyle(.roundedBorder)
                
                Text("Password")
                SecureField("", text: $password).textFieldStyle(.roundedBorder)
            }.padding().padding()
            
            Button(action: {
                if email != "" && password != "" {
                    dbConnection.LoginUser(email: email, password: password)
                }
            }, label: {
                Text("Log in").padding().background(.gray).foregroundColor(.white).cornerRadius(7)
            })
            
            // Måste vara inuti en navigationView för att använda NavigationLink
            NavigationLink(destination: RegisterPage(dbConnection: dbConnection), label: {
                Text("Register")
            }).padding().foregroundColor(.blue)
            
           
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        //ContentView()
        //RegisterPage()
        //LoginPage(dbConnection: DatabaseConnection())
        MainPage(dbConnection: DatabaseConnection())
    }
}
