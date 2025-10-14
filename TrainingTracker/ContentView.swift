//
//  ContentView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/7/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        //tab view navigation
        MainTabView()
    }
}

#Preview {
    ContentView()
}
