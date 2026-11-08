// Poni kaca di tengah atas: orb saat Jarvis bicara/mendengar, info lagu saat berganti.
// Jalankan: qs -c jarvis-island     Kendali: qs -c jarvis-island ipc call island <fungsi> ...
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris

ShellRoot {
    id: root

    // ---- warna dari skema Caelestia (ikut wallpaper) ----
    property var c: ({})
    function col(name, alpha) {
        const hex = c[name] ?? "888888";
        return Qt.rgba(parseInt(hex.substr(0, 2), 16) / 255, parseInt(hex.substr(2, 2), 16) / 255,
                       parseInt(hex.substr(4, 2), 16) / 255, alpha ?? 1);
    }
    FileView {
        path: Quickshell.env("HOME") + "/.local/state/caelestia/scheme.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { root.c = JSON.parse(text()).colours; } catch (e) {}
        }
    }

    // ---- status: idle | media | speak | listen | think ----
    property string mode: "idle"
    property string caption: ""
    property var envelope: []
    property int envIndex: 0
    property real level: 0

    readonly property MprisPlayer player: Mpris.players.values.find(p => p.identity === "Spotify")
        ?? Mpris.players.values.find(p => p.playbackState === MprisPlaybackState.Playing) ?? null
    readonly property bool playing: player?.playbackState === MprisPlaybackState.Playing

    function show(m, ms) {
        mode = m;
        hideTimer.interval = ms;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        onTriggered: root.mode = "idle"
    }

    Connections {
        target: root.player
        function onTrackTitleChanged() {
            if (root.mode === "idle" || root.mode === "media")
                root.show("media", 4000);
        }
    }

    // orb mengikuti amplitudo suara (envelope per 50 ms dari script jarvis)
    Timer {
        id: envTimer
        interval: 50
        repeat: true
        onTriggered: {
            if (root.envIndex < root.envelope.length)
                root.level = root.envelope[root.envIndex++];
            else
                root.level = 0;
        }
    }
    // denyut pelan saat mendengar / berpikir
    property real breath: 0
    SequentialAnimation on breath {
        running: root.mode === "listen" || root.mode === "think"
        loops: Animation.Infinite
        NumberAnimation { to: 1; duration: 700; easing.type: Easing.InOutSine }
        NumberAnimation { to: 0; duration: 700; easing.type: Easing.InOutSine }
    }

    IpcHandler {
        target: "island"
        function speak(text: string, env: string, ms: int): void {
            root.caption = text;
            root.envelope = env.split(",").map(Number);
            root.envIndex = 0;
            envTimer.restart();
            root.show("speak", ms + 600);
        }
        function hear(): void { root.caption = "Listening..."; root.show("listen", 10000); }
        function think(): void { root.caption = "Thinking..."; root.show("think", 30000); }
        function idle(): void { root.mode = "idle"; }
    }

    PanelWindow {
        anchors.top: true
        margins.top: 4
        implicitWidth: 620
        implicitHeight: 96
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "jarvis-island"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        mask: Region { item: pill }

        Rectangle {
            id: pill

            readonly property bool open: root.mode !== "idle"
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            width: root.mode === "media" ? 440 : root.mode === "speak" ? Math.min(580, 120 + caption.implicitWidth)
                 : open ? 240 : (root.playing ? 150 : 120)
            height: open ? 62 : 30
            radius: height / 2
            color: root.col("surfaceContainer", 0.62)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)
            clip: true

            // efek "liquid": pegas sedikit memantul saat melebar
            Behavior on width { SpringAnimation { spring: 4; damping: 0.28; epsilon: 0.5 } }
            Behavior on height { SpringAnimation { spring: 4; damping: 0.32; epsilon: 0.5 } }

            // kilau kaca di bagian atas
            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
                height: parent.height / 2
                radius: parent.radius
                gradient: Gradient {
                    GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.10) }
                    GradientStop { position: 1; color: Qt.rgba(1, 1, 1, 0) }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: if (root.player) root.show("media", 5000)
            }

            // ---- idle: tiga bar kecil saat musik diputar ----
            Row {
                anchors.centerIn: parent
                spacing: 3
                opacity: !pill.open && root.playing ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                Repeater {
                    model: 3
                    Rectangle {
                        required property int index
                        width: 3; radius: 1.5
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.col("primary")
                        SequentialAnimation on height {
                            running: root.playing
                            loops: Animation.Infinite
                            NumberAnimation { to: 12; duration: 300 + index * 120; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 4; duration: 300 + index * 120; easing.type: Easing.InOutSine }
                        }
                    }
                }
            }

            // ---- orb (bicara / mendengar / berpikir) ----
            Item {
                id: orb
                width: 40; height: 40
                anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                opacity: ["speak", "listen", "think"].includes(root.mode) ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                readonly property real amp: root.mode === "speak" ? root.level : root.breath * 0.5

                Rectangle {
                    anchors.centerIn: parent
                    width: 22 + orb.amp * 18; height: width; radius: width / 2
                    color: root.col("primary", 0.25)
                    Behavior on width { NumberAnimation { duration: 60 } }
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: 16 + orb.amp * 8; height: width; radius: width / 2
                    color: root.mode === "listen" ? root.col("tertiary") : root.col("primary")
                    Behavior on width { NumberAnimation { duration: 60 } }
                }
            }

            Text {
                id: caption
                anchors { left: orb.right; leftMargin: 12; verticalCenter: parent.verticalCenter }
                width: Math.min(implicitWidth, 450)
                text: root.caption
                elide: Text.ElideRight
                color: root.col("onSurface")
                font { family: "SF Pro Text"; pixelSize: 15 }
                opacity: ["speak", "listen", "think"].includes(root.mode) ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // ---- lagu ----
            Row {
                anchors { left: parent.left; leftMargin: 9; verticalCenter: parent.verticalCenter }
                spacing: 12
                opacity: root.mode === "media" ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Rectangle {
                    width: 44; height: 44; radius: 22; clip: true
                    color: root.col("secondaryContainer")
                    Image {
                        anchors.fill: parent
                        source: root.player?.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                        sourceSize { width: 88; height: 88 }
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 340
                    Text {
                        width: parent.width
                        text: root.player?.trackTitle ?? ""
                        elide: Text.ElideRight
                        color: root.col("onSurface")
                        font { family: "SF Pro Display"; pixelSize: 15; weight: Font.DemiBold }
                    }
                    Text {
                        width: parent.width
                        text: root.player?.trackArtist ?? ""
                        elide: Text.ElideRight
                        color: root.col("onSurfaceVariant")
                        font { family: "SF Pro Text"; pixelSize: 13 }
                    }
                }
            }
        }
    }
}
