import Darwin

struct TrafficRate {
    let download: Double
    let upload: Double

    static let zero = TrafficRate(download: 0, upload: 0)
}

struct TrafficMonitor {
    private struct Counters {
        let received: UInt64
        let sent: UInt64
    }

    private struct Snapshot {
        let time: ContinuousClock.Instant
        let interfaces: [String: Counters]
    }

    private var previous: Snapshot?

    mutating func sample() -> TrafficRate? {
        let current = Self.readSnapshot()
        let baseline = previous
        previous = current

        guard let current, let baseline else { return nil }

        let elapsed = baseline.time.duration(to: current.time).components
        let seconds = Double(elapsed.seconds) + Double(elapsed.attoseconds) / 1e18
        guard seconds > 0, seconds <= 5 else { return nil }

        var received = 0.0
        var sent = 0.0
        for (name, counters) in current.interfaces {
            // 新接入的网卡和被重置的计数器需要重新建立基准。
            guard let old = baseline.interfaces[name],
                  counters.received >= old.received,
                  counters.sent >= old.sent else { continue }
            received += Double(counters.received - old.received)
            sent += Double(counters.sent - old.sent)
        }

        return TrafficRate(download: received / seconds, upload: sent / seconds)
    }

    private static func readSnapshot() -> Snapshot? {
        guard let interfaces = if_nameindex() else { return nil }
        defer { if_freenameindex(interfaces) }

        var counters: [String: Counters] = [:]
        var entry = interfaces
        while let interfaceName = entry.pointee.if_name {
            let index = entry.pointee.if_index
            entry += 1

            let name = String(cString: interfaceName)
            // enN 涵盖常见 Wi-Fi 和有线网卡，跳过回环、桥接和 VPN 隧道。
            guard name.hasPrefix("en"), UInt32(name.dropFirst(2)) != nil else { continue }

            var mib = [CTL_NET, PF_LINK, NETLINK_GENERIC, IFMIB_IFDATA,
                       Int32(bitPattern: index), IFDATA_GENERAL]
            let mibCount = UInt32(mib.count)
            var data = ifmibdata()
            var size = MemoryLayout<ifmibdata>.size
            guard sysctl(&mib, mibCount, &data, &size, nil, 0) == 0,
                  size == MemoryLayout<ifmibdata>.size,
                  data.ifmd_flags & UInt32(IFF_UP) != 0 else { continue }

            counters[name] = Counters(
                received: data.ifmd_data.ifi_ibytes,
                sent: data.ifmd_data.ifi_obytes
            )
        }

        return Snapshot(time: .now, interfaces: counters)
    }
}
