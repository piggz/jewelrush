import QtQuick 2.0

Rectangle {
    signal exitClicked();
    property bool onScreen: false;
    opacity: onScreen ? 1 : 0
    visible: opacity > 0.2;

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    Image {
        id: background
        source: "pics/back.png"
        smooth: true
        z: 0
        fillMode: Image.Stretch
        anchors.fill: parent
    }

    CloseButton {
        id: closebutton
        width: Helper.mmToPixels(7);

        onClicked: {
            exitClicked();
        }
    }

    Rectangle {
        id: boardBack
        border.color: "white"
        border.width:5
        color: "#000000"
        opacity: 0.6
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: height/2
        height: parent.height - 40
        anchors.margins: 20

    }
    Item {
        anchors.fill: boardBack
        anchors.margins: Helper.mmToPixels(2)

        Column {
            anchors.fill: parent
            spacing: 30
            Text {
                id: audioHeader
                font.family: gameFont.name
                text: "Audio"
                color: "#ffffff"
                font.pixelSize: Helper.mmToPixels(7)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                spacing: 30
                Image {
                    id: sfxIcon
                    source: "pics/sound.png"
                    anchors.verticalCenter: parent.verticalCenter
                }
                PGZSlider {
                    id: sfxVolume
                    value: optSfxVolume
                    width: 150
                    height: 70
                    //highlighted: selectedItem === 1
                    anchors.verticalCenter: parent.verticalCenter
                    onSliderChanged: {
                        optSfxVolume = new_value;
                    }
                }
            }

            Row {
                spacing: 30
                Image {
                    id: musicIcon
                    source: "pics/music.png"
                    anchors.verticalCenter: parent.verticalCenter
                    width: sfxIcon.width
                    fillMode: Image.PreserveAspectFit

                }

                PGZSlider {
                    id: musicVolume
                    value: optMusicVolume
                    width: 150
                    height: 70
                    anchors.verticalCenter: parent.verticalCenter
                    //highlighted: selectedItem === 2

                    onSliderChanged: {
                        optMusicVolume = new_value;
                    }
                }
            }
        }
    }
}
