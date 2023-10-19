import SwiftUI
import SwiftData
import Combine

struct RecordMeetingView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(SpeechRecognizer.self) private var speechRecognizer
  var standup: Standup
  @State var secondsElapsed: Int = 0
  @State var speakerIndex: Int = 0
  var body: some View {
    VStack {
      header
      Spacer()
      timerView
      Spacer()
      footer
    }
    .padding()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background {
        Rectangle().fill(standup.theme.mainColor.gradient)
      }
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .padding()
      .foregroundColor(standup.theme.accentColor)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button {
            dismiss()
          } label: {
            Text("End Meeting")
          }
        }
      }
      .navigationBarBackButtonHidden(true) 
      .customSensoryFeedback(.init(soundFilename: "ding.wav"), trigger: speakerIndex)
      .task {
        for await _ in AsyncPublisher(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) {
          secondsElapsed += 1
          if secondsElapsed.isMultiple(of: Int(standup.durationPerAttendee.components.seconds)) {
            let nextSpeakerIndex = speakerIndex + 1
            if standup.attendees.indices.contains(nextSpeakerIndex) {
              speakerIndex = nextSpeakerIndex
            } else {
//              finish()
            }
          }
        }
      }
  }
  
  @ViewBuilder
  var header: some View {
    ProgressView(value: progress)
      .progressViewStyle(MeetingProgressViewStyle(theme: standup.theme))
    HStack {
      VStack(alignment: .leading) {
        Text("Time Elapsed")
        Label(
          Duration.seconds(self.secondsElapsed).formatted(.units()),
          systemImage: "hourglass.bottomhalf.fill"
        )
      }
      Spacer()
      VStack(alignment: .trailing) {
        Text("Time Remaining")
        Label(
          (standup.duration - Duration.seconds(secondsElapsed)).formatted(.units()),
          systemImage: "hourglass.bottomhalf.fill"
        )
      }
    }
  }
  
  @ViewBuilder
  var timerView: some View {
    Circle()
      .strokeBorder(lineWidth: 24)
      .overlay {
        VStack {
          Group {
            if speakerIndex < standup.attendees.count {
              Text(standup.attendees[speakerIndex].name)
            } else {
              Text("Someone")
            }
          }
          .font(.title)
          Text("is speaking")
          Image(systemName: "mic.fill")
            .font(.largeTitle)
            .padding(.top)
        }
        .foregroundStyle(standup.theme.accentColor)
      }
      .overlay {
        ForEach(Array(standup.attendees.enumerated()), id: \.element.id) { index, attendee in
          if index < self.speakerIndex + 1 {
            SpeakerArc(totalSpeakers: standup.attendees.count, speakerIndex: index)
              .rotation(Angle(degrees: -90))
              .stroke(standup.theme.mainColor, lineWidth: 12)
          }
        }
      }
      .padding(.horizontal)
  }
  
  @ViewBuilder
  var footer: some View {
    HStack {
      Text("Speaker \(speakerIndex + 1) of \(standup.attendees.count)")
      Spacer()
      Button {
        next()
      } label: {
        Image(systemName: "forward.fill")
      }
    }
  }
  
  var next: () -> Void {{
    speakerIndex += 1
    //TODO: advance time
  }}
  
  private var progress: Double {
    return max(0, min(1, Double(self.secondsElapsed) / Double(standup.duration.components.seconds)))
  }
}

struct SpeakerArc: Shape {
  let totalSpeakers: Int
  let speakerIndex: Int

  func path(in rect: CGRect) -> Path {
    let diameter = min(rect.size.width, rect.size.height) - 24.0
    let radius = diameter / 2.0
    let center = CGPoint(x: rect.midX, y: rect.midY)
    return Path { path in
      path.addArc(
        center: center,
        radius: radius,
        startAngle: self.startAngle,
        endAngle: self.endAngle,
        clockwise: false
      )
    }
  }

  private var degreesPerSpeaker: Double {
    360.0 / Double(self.totalSpeakers)
  }
  private var startAngle: Angle {
    Angle(degrees: self.degreesPerSpeaker * Double(self.speakerIndex) + 1.0)
  }
  private var endAngle: Angle {
    Angle(degrees: self.startAngle.degrees + self.degreesPerSpeaker - 1.0)
  }
}


struct MeetingProgressViewStyle: ProgressViewStyle {
  var theme: Theme

  func makeBody(configuration: Configuration) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10.0)
        .fill(theme.accentColor)
        .frame(height: 20.0)

      ProgressView(configuration)
        .tint(theme.mainColor)
        .frame(height: 12.0)
        .padding(.horizontal)
    }
  }
}


#Preview {
  let modelContainer = try! ModelContainer(for: Standup.self, configurations: .init(isStoredInMemoryOnly: true))
  let standup = Standup.sample
  standup.duration = .seconds(10)
  modelContainer.mainContext.insert(standup)
  return NavigationStack {
    RecordMeetingView(standup: standup)
      .modelContainer(modelContainer)
  }
}
