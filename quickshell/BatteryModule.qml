import QtQuick
import Quickshell.Services.UPower

BarText {
    id: root
    color: Theme.green

    property var device: UPower.displayDevice

    // UPowerDeviceState: 1=Charging, 4=FullyCharged, 5=PendingCharge
    text: {
        if (!device || !device.isPresent) return "bat --%"
        const pct = Math.round(device.percentage)
        const state = device.state
        const prefix = state === 1 ? "+" : state === 4 || state === 5 ? "=" : ""
        return "bat " + prefix + pct + "%"
    }
}
