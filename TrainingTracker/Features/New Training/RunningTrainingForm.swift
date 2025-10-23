//
//  RunningTrainingForm.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//
import SwiftUI
import SwiftData

struct RunningTrainingForm: View {
    
    @State private var date = Date()
    @State private var distance = ""
    @State private var duration = ""
    @State private var notes = ""
    
    
    var body: some View {
        Form {
            Section("Running Details") {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                
                HStack {
                    Text("Distance (km)")
                    Spacer()
                    TextField("0", text: $distance)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                
                HStack {
                    Text("Duration (h:mm:ss)")
                    Spacer()
                    TextField("0:00:00", text: $duration)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 90)
                        .onChange(of: duration) { newValue in
                            duration = formatDurationInput(newValue)
                        }
                }
                
            }
            Section("Notes") {
                TextField("Optional notes…", text: $notes, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
            Section {
                Button(action: saveRunningTraining) {
                    Text("Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 40, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .listRowBackground(Color.clear)
            }
        }
        
    }
    /* funcion para guardar el entranamiento */
    private func saveRunningTraining() {
            print("Running training saved:")
            print("- Date: \(date)")
            print("- Distance: \(distance) km")
            print("- Duration: \(duration)")
            print("- Notes: \(notes)")
    }
    
    /* funcion para crear mascara del formato h:mm:ss */
    private func formatDurationInput(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }

        var result = ""
        let chars = Array(digits)

        // h:mm:ss → máximo 6 dígitos
        if chars.count > 0 {
            result.append(chars[0])
        }
        if chars.count > 1 {
            result.append(":")
            result.append(chars[1])
        }
        if chars.count > 2 {
            result.append(chars[2])
        }
        if chars.count > 3 {
            result.append(":")
            result.append(chars[3])
        }
        if chars.count > 4 {
            result.append(chars[4])
        }
        if chars.count > 5 {
            result.append(chars[5])
        }
        return String(result.prefix(8))
    }
        
        

}
