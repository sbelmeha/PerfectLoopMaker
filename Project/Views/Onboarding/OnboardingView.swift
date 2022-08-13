//
//  OnboardingView.swift
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 02.07.2022.
//

import SwiftUI

protocol OnboardingViewItem {
    var id: String { get }
    var view: AnyView { get }
    var action: (() -> Void)? { get }
}

struct OnboardingViewItemolder: Identifiable, Hashable {
    static func == (lhs: OnboardingViewItemolder, rhs: OnboardingViewItemolder) -> Bool {
        return lhs.id == rhs.id
    }
    
    let item: OnboardingViewItem
    
    var id: String {
        return item.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct RoundedBorderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .contentShape(Rectangle()) 
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 2)
                    .padding(2)
            )
            .opacity(configuration.isPressed ? 0.35 : 1)
    }
}

struct WelcomeOnboardingViewItem: OnboardingViewItem {
    var id: String
    
    var action: (() -> Void)?
    var skipAction: (() -> Void)?
    
    var view: AnyView {
        AnyView(VStack(alignment: .leading) {
            
            Label {
                Text("Welcome")
                    .foregroundColor(.white)
                    .font(.system(size: 36))
                    .fontWeight(.bold)
            } icon: {
                Image(systemName: "infinity")
                    .renderingMode(.template)
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                
            }
            .padding(.bottom, 8)
            
            Text("Make your video endless, using AI this app loops video without a visible transition between cut frames.")
                .foregroundColor(.white)
                .font(.system(size: 18))
                .padding(.bottom, 16)
            
            Button {
                action?()
            } label: {
                Text("Tutorial")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(RoundedBorderButtonStyle())
            .foregroundColor(.white)
            
            Button {
                skipAction?()
            } label: {
                Text("Skip")
                    .font(.system(size: 16))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .opacity(0.7)
            }
            .foregroundColor(.white)
        })
    }
}

struct HowToOnboardingViewItem: OnboardingViewItem {
    var id: String
    
    var action: (() -> Void)?
    
    var view: AnyView {
        AnyView(VStack(alignment: .leading) {
            Text("How To")
                .foregroundColor(.white)
                .font(.system(size: 36))
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            
            Image("how_to_pic")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 8)
                )
                .padding(.bottom, 16)
            
            Text("1. Select a video from your gallery")
                .foregroundColor(.white)
                .font(.system(size: 16))
                .padding(.bottom, 4)
            
            
            Text("2. Move sliders to find 2 similar frames, on the preview you will see one frame overlaying another, the less differences are on the selected frames, the better result you will get.")
                .foregroundColor(.white)
                .font(.system(size: 16))
                .padding(.bottom, 16)
            
            HStack {
                Button {
                    action?()
                } label: {
                    Text("Examples")
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(RoundedBorderButtonStyle())
                .foregroundColor(.white)
            }
            
        })
    }
}

struct ExamplesOnboardingViewItem: OnboardingViewItem {
    var id: String
    
    var action: (() -> Void)?
    
    var view: AnyView {
        AnyView(VStack(alignment: .leading) {
            
            Spacer()
            
            Text("Examples")
                .foregroundColor(.white)
                .font(.system(size: 36))
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            HStack(alignment: .bottom, spacing: 16) {
                
                VStack {
                    Text("Bad")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    Image("bad_example")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                }
                .padding(4)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 8)
                )
                
                
                VStack {
                    Text("Good")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Image("good_example")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                }
                .padding(4)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 8)
                )
                
            }
            .padding(.bottom)
            
            HStack(alignment: .top, spacing: 16) {
                Text("Frames do not match, as a result the transition will be glitchy.")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    
                Text("After frame sliders adjustments the frames match almost perfecty, the AI will do te rest to get the best result.")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            .padding(.bottom)
            
            Button {
                action?()
            } label: {
                Text("Get started")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(RoundedBorderButtonStyle())
            .foregroundColor(.white)
        })
    }
}

struct OnboardingView: View {
    
    @ObservedObject var viewModel: OnboardingViewModel
    
    @State var blurRadius : CGFloat = 0
    
    var body: some View {
        ZStack {
            PlayerView(url: Bundle.main.url(forResource: "marilyn", withExtension: "MP4")!)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .blur(radius: blurRadius)
                .onChange(of: viewModel.currentPage) { page in
                    withAnimation {
                        blurRadius = page.item is WelcomeOnboardingViewItem ? 0 : 16
                    }
                }
            
            TabView(selection: $viewModel.currentPage) {
                ForEach(0..<viewModel.onboardingViewItems.count) { index in
                    VStack(alignment: .leading) {
                        Spacer()
                        viewModel.onboardingViewItems[index].item.view
                    }
                    .tag(viewModel.onboardingViewItems[index])
                    .padding(.horizontal, 36)
                    .padding(.bottom, 56)
                }
            }
            .tabViewStyle(.page)
        }
    }
}

//struct OnboardingView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardingView()
//    }
//}
