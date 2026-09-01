//
//  RootView.swift
//  You
//

import SwiftUI

/// The app's two main areas: understanding results (Home) and acting on them (Follow-ups).
/// Mirrors the two halves of the A1 challenge statement — understand, then complete.
struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "heart.text.square")
                }

            FollowUpsView()
                .tabItem {
                    Label("Follow-ups", systemImage: "checklist")
                }
        }
    }
}

#Preview {
    RootView()
}
