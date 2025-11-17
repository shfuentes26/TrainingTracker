//
//  RunningTrainingForm.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//
import SwiftUI
import SwiftData
///Formulario para crear un entrenamiento de carrera
struct RunningTrainingForm: View {
    
    @State private var date = Date()
    @State private var distance = ""
    @State private var duration = ""
    @State private var notes = ""
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = NewTrainingViewModel()
    
    var body: some View {
        Form {
            Section("Running Details") {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                
                HStack {
                    Text("Distance (km)")
                    Spacer()
                    TextField("0", text: $vm.distanceText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                
                HStack {
                    Text("Duration (h:mm:ss)")
                    Spacer()
                    TextField("0:45:00", text: $vm.durationText)
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 90)
                }
            }
            Section("Notes") {
                TextField("Optional notes…", text: $vm.notes, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
            Section {
                Button(action: { vm.save(using: modelContext) }) {   
                    Text("Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .listRowBackground(Color.clear)
            }
        }
        .alert(vm.alert?.title ?? "",
               isPresented: Binding(get: { vm.alert != nil }, set: { if !$0 { vm.alert = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.alert?.message ?? "")
        }
        
    }
}
