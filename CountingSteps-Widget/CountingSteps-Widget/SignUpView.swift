//
//  SignUpView.swift
//  CountingSteps-Widget
//
//  Created by Kassandra Beas on 4/17/25.


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var error = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.2196078449, blue: 0.2196078449, alpha: 1))]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    VStack(spacing: 15) {
                        Image(systemName: "figure.walk.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                            )
                            .padding(.top, 50)
                        
                        Text("Create Account")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Start tracking your fitness goals today")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    VStack(spacing: 25) {
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: "person")
                                        .foregroundColor(.white.opacity(0.5))
                                    TextField("", text: $name)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: "at")
                                        .foregroundColor(.white.opacity(0.5))
                                    TextField("", text: $username)
                                        .foregroundColor(.white)
                                        .autocapitalization(.none)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(.white.opacity(0.5))
                                    TextField("", text: $email)
                                        .foregroundColor(.white)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundColor(.white.opacity(0.5))
                                    SecureField("", text: $password)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack {
                                    Image(systemName: "lock.shield")
                                        .foregroundColor(.white.opacity(0.5))
                                    SecureField("", text: $confirmPassword)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                            }
                            
                            if !error.isEmpty {
                                Text(error)
                                    .font(.footnote)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        Button {
                            if password != confirmPassword {
                                error = "Passwords do not match"
                                return
                            }
                            
                            isLoading = true
                            Auth.auth().createUser(withEmail: email, password: password) { result, err in
                                isLoading = false
                                if let err = err {
                                    error = err.localizedDescription
                                } else if let user = result?.user {
                                    let db = Firestore.firestore()
                                    db.collection("users").document(user.uid).setData([
                                        "email": email,
                                        "name": name,
                                        "username": username,
                                        "stepGoal": 20000 // default value
                                    ]) { error in
                                        if let error = error {
                                            self.error = "Failed to save user data: \(error.localizedDescription)"
                                        } else {
                                            dismiss()
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.trailing, 5)
                                }
                                Text("Create Account")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading)
                        
                        Button {
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .font(.footnote)
                                Text("Back to Login")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 30)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
