import Swafka
import SwiftUI

struct PollingIntervalView: View {
    
    @Binding var interval: Double

    
    var body: some View {
        HStack {
            Text("Polling Interval")
                .font(.headline)
            Spacer()
            Menu("\(String(interval)) sec") {
                Button("1s") {
                    Swafka.shared.publish(topic: PollingInterval(interval: 1))
                }
                Button("2s") {
                    Swafka.shared.publish(topic: PollingInterval(interval: 2))
                }
                Button("3s") {
                    Swafka.shared.publish(topic: PollingInterval(interval: 3))
                }
                Button("5s") {
                    Swafka.shared.publish(topic: PollingInterval(interval: 5))
                }
                Button("8s") {
                    Swafka.shared.publish(topic: PollingInterval(interval: 8))
                }
                Button("13s") {
                    Swafka.shared.publish(topic: PollingInterval(interval: 13))
                }
            }
        }
        .padding(10)
    }
}
