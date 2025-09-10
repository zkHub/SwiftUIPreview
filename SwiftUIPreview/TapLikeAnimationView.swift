import SwiftUI

struct TapLikeAnimationView: View {
    // 1. 状态管理
    @State private var particles: [Particle] = []
    @State private var tapCount = 0
    @State private var lastTapTime: Date?
    
    // 双击手势
    private var doubleTapGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onEnded { value in
                handleTap(at: value.location)
            }
    }
    
    private func handleTap(at location: CGPoint) {
        let now = Date()
        if let lastTime = lastTapTime, now.timeIntervalSince(lastTime) < 0.3 {
            tapCount += 1
            if tapCount == 2 { // 双击触发
                addParticle(at: location)
                tapCount = 0
            }
        } else {
            tapCount = 1
        }
        lastTapTime = now
    }
    
    private func addParticle(at location: CGPoint) {
        let angle = [Angle.radians(.pi/8), .zero, .radians(.pi * 15/8)].randomElement()!
        let newParticle = Particle(location: location, angle: angle)
        particles.append(newParticle)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            particles.removeAll { $0.id == newParticle.id }
        }
    }
    
    var body: some View {
        ZStack {
            // 3. 主视图（绑定手势）
            Color.white
                .contentShape(Rectangle())
                .gesture(doubleTapGesture)
            
            // 4. 粒子动画层
            ForEach(particles) { particle in
                ParticleView(particle: particle)
            }
        }
    }
}

// 5. 粒子数据模型
struct Particle: Identifiable {
    let id = UUID()
    let location: CGPoint
    let angle: Angle
}

// 6. 粒子动画组件
struct ParticleView: View {
    let particle: Particle
    @State private var isActive = false
    
    var body: some View {
        Image("icon_heart") // 替换为你的 "like" 图片
            .resizable()
            .frame(width: 30, height: 30)
            .rotationEffect(particle.angle) // 随机旋转
            .scaleEffect(isActive ? 5 : 1) // 缩放
            .opacity(isActive ? 0 : 1) // 淡出
            .animation(.linear(duration: 0.5), value: isActive) // 0.5秒线性动画
            .position(x: particle.location.x, y: particle.location.y)
            .onAppear {
                isActive = true
            }
    }
}
