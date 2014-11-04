import QtQuick 2.0

Rectangle {
    id: introWindow

    property bool onScreen: false;
    opacity: onScreen ? 1 : 0
    visible: opacity > 0;
    Behavior on opacity {
        NumberAnimation {duration: 400}
    }

    color: "#000000"


    Text {
        id: txtLoading
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: imgStudio.bottom
        anchors.topMargin: 50

        text: "Loading..."
        color: "white"
        visible: true
        state: "VISIBLE"
        states: [
            State {
                name: "HIDDEN"
                PropertyChanges { target: txtLoading; opacity: 0}
            },
            State {
                name: "VISIBLE"
                PropertyChanges { target: txtLoading; opacity: 1}
            }
        ]

        transitions: Transition {
            NumberAnimation { target: txtLoading; properties: "opacity"; easing.type: Easing.Linear; duration: 1000 }
        }
    }

    Image {
        id: imgStudio
        source: "pics/pgz-studio.svg"
        state: "VISIBLE"
        anchors.centerIn: parent

        states: [
            State {
                name: "HIDDEN"
                PropertyChanges { target: imgStudio; opacity: 0}
            },
            State {
                name: "VISIBLE"
                PropertyChanges { target: imgStudio; opacity: 1}
            }
        ]

        transitions: Transition {
            NumberAnimation { target: imgStudio; properties: "opacity"; easing.type: Easing.Linear; duration: 1000 }
        }
    }

    Timer {
        repeat: false
        interval: 500
        running:  true

        onTriggered: {
            txtLoading.state = "HIDDEN"
            imgStudio.state = "HIDDEN"
        }
    }
}
