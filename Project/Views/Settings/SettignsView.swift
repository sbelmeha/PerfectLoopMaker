//
//  SettignsView.swift
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 03.07.2022.
//

import SwiftUI
import MessageUI

struct SettignsView: View {
    
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        NavigationView {
            
            VStack {
                List() {
                    settingsSection
                    
                    infoSection
                    
                    Text("Version: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) Beta")
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $isShowingMailView) {
            MailView(result: self.$result)
        }
        .sheet(isPresented: $isOnboardingPresented, content: {
            OnboardingView(viewModel: onboardingViewModel)
        })
        .onChange(of: isOnboardingPresented, perform: { new in
            onboardingViewModel.currentPage = onboardingViewModel.onboardingViewItems[0]
        })
        .onAppear {
            onboardingViewModel.closeAction = {
                isOnboardingPresented = false
            }
        }
    }
    
    // MARK: - Private
    
    @State private var isOnboardingPresented = false
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    @State private var isShowingMailView = false
    
    private var settingsSection: some View {
        Section() {
            VStack(alignment: .leading) {
                Text("What quality do you prefer?")
                Picker("", selection: $viewModel.quality) {
                    Text("🚀 Low").tag(0)
                    Text("Medium").tag(1)
                    Text("🐌 High").tag(2)
                }
                .pickerStyle(.segmented)
                
                Text("The higher quality is the longer it will take to process the video.")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding(.top, 8)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Scale")
                    Slider(value: $viewModel.scaleValue, in: 1.0...3.0, step: 1, minimumValueLabel: Text("1"), maximumValueLabel: Text("3")) {
                        EmptyView()
                    }
                }
                
                HStack {
                    Text("Blur")
                    Slider(value: $viewModel.blurValue, in: 1.0...16.0, step: 1, minimumValueLabel: Text("1"), maximumValueLabel: Text("16")) {
                        EmptyView()
                    }
                }
                
                Text("These settings may affect the result, you can experiment with them and see what works better for your video.")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
        }
    }
    
    private var infoSection: some View {
        Section() {
            Button {
                isOnboardingPresented = true
            } label: {
                Text("How it works? 🐣")
            }
            
            Link("Get inspiration 📽️", destination: URL(string: "https://www.tiktok.com/@endless.videos")!)
            
            Button {
                isShowingMailView = true
            } label: {
                Text("Send feedback ✉️")
            }
            .disabled(!MFMailComposeViewController.canSendMail())
        }
    }
}
