//
//  OnboardingViewModel.swift
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 10.07.2022.
//

import Combine
import SwiftUI

class OnboardingViewModel: ObservableObject {
    
    @Published var currentPage: OnboardingViewItemolder = .init(item: WelcomeOnboardingViewItem(id: "1", action: nil))
    var closeAction: (() -> Void)?
    
    var onboardingViewItems: [OnboardingViewItemolder] {
        return [
            OnboardingViewItemolder(item: WelcomeOnboardingViewItem(id: "1", action: next, skipAction: close)),
            OnboardingViewItemolder(item: HowToOnboardingViewItem(id: "2", action: next)),
            OnboardingViewItemolder(item: ExamplesOnboardingViewItem(id: "3", action: close))
        ]
    }
    
    func next() {
        var index = onboardingViewItems.firstIndex(of: currentPage) ?? 0
        if index < onboardingViewItems.count - 1 {
            index += 1
        } else {
            index = 0
        }
        withAnimation {
            currentPage = onboardingViewItems[index]
        }
    }
    
    func close() {
        closeAction?()
    }
}
