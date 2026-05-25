import SwiftUI

struct ReferenceGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: GuideCategory = .tvWiring

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(GuideCategory.allCases) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    Text(category.title)
                                        .font(.subheadline.bold())
                                        .foregroundColor(selectedCategory == category ? .white : .white.opacity(0.5))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category
                                            ? AnyShapeStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                                            : AnyShapeStyle(Color.white.opacity(0.08))
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }

                    Divider().background(Color.white.opacity(0.1))

                    // Content
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(selectedCategory.items) { item in
                                GuideItemCard(item: item)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Reference Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .bold()
                        .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Guide card

struct GuideItemCard: View {
    let item: GuideItem
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
            } label: {
                HStack {
                    Text(item.title)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.caption)
                }
                .padding(14)
            }

            if expanded {
                Divider().background(Color.white.opacity(0.1))
                VStack(alignment: .leading, spacing: 10) {
                    Text(item.content)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))

                    if let videoId = item.youtubeId {
                        Link(destination: URL(string: "https://youtube.com/watch?v=\(videoId)")!) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(.red)
                                Text("Watch on YouTube")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding(14)
            }
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.18))
        .cornerRadius(14)
    }
}

// MARK: - Data

enum GuideCategory: String, CaseIterable, Identifiable {
    case tvWiring, soundbars, cameras, thermostats, networking, smartHome

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tvWiring: return "📺 TV Wiring"
        case .soundbars: return "🔊 Soundbars"
        case .cameras: return "📷 Cameras"
        case .thermostats: return "🌡️ Thermostats"
        case .networking: return "📶 Networking"
        case .smartHome: return "🏠 Smart Home"
        }
    }

    var items: [GuideItem] {
        switch self {
        case .tvWiring:
            return [
                GuideItem(title: "HDMI Connections", content: "HDMI 2.1 supports 4K@120Hz. Use HDMI 2.0 for 4K@60Hz. Connect cable boxes to HDMI 1 on most TVs. ARC/eARC port (usually HDMI 2) for soundbar audio. Always check HDMI handshake if no signal.", youtubeId: nil),
                GuideItem(title: "Wall Mount — Stud Finder Tips", content: "Studs are typically 16\" or 24\" on center. Use magnetic stud finder for older walls. Mark both edges of stud, mount bracket to center. Use lag bolts (not drywall anchors) rated for 4× TV weight.", youtubeId: nil),
                GuideItem(title: "Cable Management", content: "In-wall kit needs two low-voltage boxes, one at TV height and one at floor. Fish power cable only inside EMT conduit per code. Use raceway if you can't go in-wall. Bundle signal cables separately from power.", youtubeId: nil),
                GuideItem(title: "TV No Signal", content: "1. Check input source on TV. 2. Reseat HDMI cable on both ends. 3. Try different HDMI port. 4. Try different cable. 5. Check HDMI handshake (power cycle both devices). 6. Factory reset display settings.", youtubeId: nil),
            ]
        case .soundbars:
            return [
                GuideItem(title: "HDMI ARC vs eARC", content: "ARC: supports Dolby Digital 5.1 and stereo. eARC: supports Dolby Atmos, DTS:X, uncompressed audio. TV and soundbar both need eARC for high-res audio. Enable 'HDMI-CEC' and 'ARC' in TV audio settings.", youtubeId: nil),
                GuideItem(title: "Sonos Arc Setup", content: "Connect via HDMI ARC. Download Sonos app. Add product → scan QR on bottom. Enable Dolby Atmos on TV audio output. Disable TV speakers. Run Trueplay tuning in app for best audio.", youtubeId: nil),
                GuideItem(title: "No Sound from Soundbar", content: "1. Verify HDMI ARC cable (not all HDMI cables support ARC). 2. Enable HDMI-CEC on TV. 3. Set TV audio output to ARC/External. 4. Disable TV internal speakers. 5. Check soundbar input mode.", youtubeId: nil),
            ]
        case .cameras:
            return [
                GuideItem(title: "Ring Doorbell Wiring", content: "Requires 16-24V AC transformer, minimum 30VA. Wire to front/back terminals (polarity doesn't matter). Bypass existing doorbell chime or use Ring Pro Power Kit v2. Test voltage at doorbell wires — needs 16V+ AC.", youtubeId: nil),
                GuideItem(title: "Arlo Camera Setup", content: "Plug base station into router via Ethernet. Add cameras in Arlo app. Hold sync button on camera until blink. Select base station in app. Position camera within 300ft of base. Test motion zones.", youtubeId: nil),
                GuideItem(title: "Camera Offline", content: "1. Check WiFi password (2.4GHz required for most cameras). 2. Move camera closer to router. 3. Power cycle camera and router. 4. Remove and re-add device in app. 5. Check account subscription status.", youtubeId: nil),
                GuideItem(title: "Nest Camera Wired", content: "Supports 802.3af PoE or 24V power adapter. Use Nest app to claim. Scan QR code on back. Strong 2.4GHz or 5GHz WiFi required. After setup, configure activity zones and notification settings.", youtubeId: nil),
            ]
        case .thermostats:
            return [
                GuideItem(title: "Thermostat Wire Colors", content: "R/Rc: 24V power (red). C: Common/ground (blue/black). Y/Y1: Cooling (yellow). G: Fan (green). W/W1: Heat (white). O/B: Heat pump reversing valve. E: Emergency heat. Always photo wires before disconnecting.", youtubeId: nil),
                GuideItem(title: "Nest Thermostat Install", content: "1. Turn off HVAC breaker. 2. Photo existing wiring. 3. Label wires with included stickers. 4. Remove old thermostat. 5. Install Nest base, connect wires to matching terminals. 6. Snap on display. 7. Follow app setup.", youtubeId: nil),
                GuideItem(title: "No C-Wire Solution", content: "Option 1: Use Nest Power Connector (repurposes G wire). Option 2: Install C-wire adapter at air handler. Option 3: Run new wire (best permanent solution). Option 4: Use battery-powered thermostat. Check if unused wire exists in bundle first.", youtubeId: nil),
            ]
        case .networking:
            return [
                GuideItem(title: "Eero Setup", content: "Plug primary eero into modem via Ethernet. Open eero app, create/login account. Add primary eero, then add additional eeros as beacons. Place beacons halfway between primary and dead zones. Run speed test after setup.", youtubeId: nil),
                GuideItem(title: "WiFi 2.4GHz vs 5GHz", content: "2.4GHz: longer range, better wall penetration, slower (max ~150Mbps practical), more interference. 5GHz: shorter range, faster (500+ Mbps), less interference. Smart home devices (cameras, thermostats) usually require 2.4GHz.", youtubeId: nil),
                GuideItem(title: "Ethernet Wall Outlet", content: "Cat6 supports 1Gbps to 100m. Use T568B standard for both ends. Punch down cable in order: orange-white, orange, green-white, blue, blue-white, green, brown-white, brown. Test with cable tester before patching.", youtubeId: nil),
            ]
        case .smartHome:
            return [
                GuideItem(title: "Google Home Setup", content: "Download Google Home app. Tap + → Set up device → New devices. Connect phone to same WiFi the device will use. Follow in-app instructions. Smart displays need power + WiFi. Speakers need power + WiFi or Ethernet.", youtubeId: nil),
                GuideItem(title: "Amazon Echo Setup", content: "Plug in Echo. Open Alexa app. Tap Devices → Add Device → Amazon Echo. Follow setup. Echo must be on 2.4GHz or 5GHz WiFi. After setup, link music services and smart home skills.", youtubeId: nil),
                GuideItem(title: "Smart Home Device Offline", content: "1. Power cycle the device. 2. Check if WiFi password changed. 3. Confirm 2.4GHz network is available. 4. Remove and re-add device in app. 5. Check router security settings (WPA2 recommended). 6. Ensure router DHCP isn't full.", youtubeId: nil),
            ]
        }
    }
}

struct GuideItem: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let youtubeId: String?
}
