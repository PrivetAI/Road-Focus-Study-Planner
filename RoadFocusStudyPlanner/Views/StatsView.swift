import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: DataStore
    
    var weekSessions: [TimerSession] { store.sessionsThisWeek() }
    var monthSessions: [TimerSession] { store.sessionsThisMonth() }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary cards
                    HStack(spacing: 12) {
                        StatCard(title: "This Week", value: String(format: "%.1fh", store.totalHours(weekSessions)))
                        StatCard(title: "This Month", value: String(format: "%.1fh", store.totalHours(monthSessions)))
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        StatCard(title: "Streak", value: "\(store.studyStreak()) days")
                        StatCard(title: "Avg Session", value: String(format: "%.0fm", store.averageSessionLength()))
                    }
                    .padding(.horizontal)
                    
                    // Most studied
                    if let top = store.hoursPerSubject(monthSessions).first {
                        HStack {
                            Text("Most Studied:")
                                .foregroundColor(AppColors.darkGray.opacity(0.6))
                            Text(top.0)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.gold)
                            Spacer()
                            Text(String(format: "%.1fh", top.1))
                                .foregroundColor(AppColors.darkGray)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Bar chart (custom, no Charts framework)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hours by Subject")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.darkGray)
                        
                        let data = store.hoursPerSubject(monthSessions)
                        let maxVal = data.first?.1 ?? 1
                        
                        if data.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    ChartIcon()
                                        .stroke(AppColors.lightGray, style: StrokeStyle(lineWidth: 2))
                                        .frame(width: 50, height: 50)
                                    Text("No data yet.\nComplete study sessions to see stats.")
                                        .font(.caption)
                                        .foregroundColor(AppColors.darkGray.opacity(0.5))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 30)
                                Spacer()
                            }
                        } else {
                            ForEach(data, id: \.0) { item in
                                HStack(spacing: 8) {
                                    Text(item.0)
                                        .font(.caption)
                                        .foregroundColor(AppColors.darkGray)
                                        .frame(width: 80, alignment: .trailing)
                                    
                                    GeometryReader { geo in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(store.colorForSubject(item.0))
                                            .frame(width: max(4, geo.size.width * CGFloat(item.1 / maxVal)))
                                    }
                                    .frame(height: 24)
                                    
                                    Text(String(format: "%.1fh", item.1))
                                        .font(.caption2)
                                        .foregroundColor(AppColors.darkGray.opacity(0.6))
                                        .frame(width: 40, alignment: .leading)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(AppColors.lightGray.opacity(0.3))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .background(Color.white)
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppColors.gold)
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.darkGray.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColors.lightGray.opacity(0.3))
        .cornerRadius(12)
    }
}
