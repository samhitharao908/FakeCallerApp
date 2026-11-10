import SwiftUI

struct ContentView: View {
    @State private var callerName = "Mom"
    @State private var callerNumber = "+1 555 123 4567"
    @State private var delaySeconds = 0.0
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Caller") {
                    TextField("Name", text: $callerName)
                    TextField("Number (optional)", text: $callerNumber)
                }
                
                Section("Delay") {
                    Slider(value: $delaySeconds, in: 0...60, step: 1)
                    Text("\(Int(delaySeconds)) seconds")
                }
                
                Button("Start Fake Call") {
                    if delaySeconds == 0 {
                        CallManager.shared.triggerFakeCall(
                            name: callerName,
                            number: callerNumber.isEmpty ? nil : callerNumber
                        )
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
                            CallManager.shared.triggerFakeCall(
                                name: callerName,
                                number: callerNumber.isEmpty ? nil : callerNumber
                            )
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Fake Call")
        }
    }
}
