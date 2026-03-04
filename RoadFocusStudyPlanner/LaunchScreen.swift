import SwiftUI

struct FocusLaunchScreen: View {
    var body: some View {
        ZStack {
            AppColors.gold
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                BookIcon()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .frame(width: 80, height: 80)
                
                Text("Road Focus")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Study Planner")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                SwiftUI.ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(.top, 20)
            }
        }
        .preferredColorScheme(.light)
    }
}
