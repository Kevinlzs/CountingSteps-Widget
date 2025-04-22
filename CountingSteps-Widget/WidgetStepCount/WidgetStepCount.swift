//
//  WidgetStepCount.swift
//  WidgetStepCount
//
//  Created by alan eckhaus on 4/15/25.
//

import WidgetKit
import SwiftUI
import HealthKit

class HealthStore {
    let healthStore = HKHealthStore()

    func fetchStepCount(completion: @escaping (Double) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            completion(steps)
        }

        healthStore.execute(query)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let steps: Int
    let goal: Int
}

struct Provider: TimelineProvider {
    let healthStore = HealthStore()
    let stepGoal = 12_000

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), steps: 7832, goal: stepGoal)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), steps: 7832, goal: stepGoal)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        healthStore.fetchStepCount { steps in
            let currentDate = Date()
            let entry = SimpleEntry(date: currentDate, steps: Int(steps), goal: stepGoal)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

struct WidgetStepCountEntryView: View {
    var entry: Provider.Entry

    var progress: Double {
        min(Double(entry.steps) / Double(entry.goal), 1.0)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.indigo)
                .ignoresSafeArea()

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.5), value: progress)

                VStack(spacing: 1) {
                    Text("Steps")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    Text("\(entry.steps.formatted())")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("/ \(entry.goal.formatted())")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding()
        }
    }
}

struct WidgetStepCount: Widget {
    let kind: String = "WidgetStepCount"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetStepCountEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetStepCountEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    WidgetStepCount()
} timeline: {
    SimpleEntry(date: .now, steps: 7832, goal: 12_000)
}
