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

        Text {
            id: hiScoreHeader
            font.family: gameFont.name
            text: "Hi Scores"
            color: "#ffffff"
            font.pixelSize: Helper.mmToPixels(7)
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Item {
            id: headerText
            anchors.top: hiScoreHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: childrenRect.height

            Text {
                id: headerScore
                y:4
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.05
                width: parent.width * 0.25
                color: "#ffffff"
                text: "Score"
                font.pixelSize: Helper.mmToPixels(4)
                font.bold: true
            }
            Text {
                id: headerLevel
                y:4
                anchors.left: headerScore.right
                anchors.leftMargin: 10
                width: parent.width * 0.25
                color: "#ffffff"
                text: "Level"
                font.pixelSize: Helper.mmToPixels(4)
                font.bold: true
            }
            Text {
                id: headerDate
                y:4
                anchors.left: headerLevel.right
                anchors.leftMargin: 10
                width: parent.width * 0.4
                color: "#ffffff"
                text: "Date"
                font.pixelSize: Helper.mmToPixels(4)
                font.bold: true
            }
        }

        ListView {
            anchors.top: headerText.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            anchors.margins: 10

            clip: true
            model: ScoreModel
            delegate: hiScoreDelegate
        }

        Component {
            id: hiScoreDelegate

            Item {
                width: parent.width
                height: levelRectangle.height

                Item {
                    id: levelRectangle
                    width:parent.width
                    height: txtScore.height + 8
                    clip: true

                    Text {
                        id: txtPosition
                        y:4
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        width: parent.width * 0.05
                        color: "#ffffff"
                        text: scoreposition + ". "
                        font.pixelSize: Helper.mmToPixels(4)
                    }

                    Text {
                        id: txtScore
                        anchors.left: txtPosition.right
                        anchors.top: txtPosition.top
                        anchors.leftMargin: 10
                        width: parent.width * 0.2
                        color: "#ffffff"
                        text: score
                        font.pixelSize: Helper.mmToPixels(4)
                    }

                    Text {
                        id:txtLevel
                        anchors.left: txtScore.right
                        anchors.leftMargin: 10
                        anchors.top: txtPosition.top
                        width: parent.width * 0.2
                        text: scorecurrentlevel
                        color: "#ffffff"
                        font.pixelSize: Helper.mmToPixels(4)
                    }

                    Text {
                        id:txtdDate
                        anchors.left: txtLevel.right
                        anchors.leftMargin: 10
                        anchors.top: txtPosition.top
                        width: parent.width * 0.2
                        text: scoredate
                        color: "#ffffff"
                        font.pixelSize: Helper.mmToPixels(4)

                    }

                }

            }
        }
    }
}
