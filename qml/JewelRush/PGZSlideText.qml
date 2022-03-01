import QtQuick 2.0

Item {
    id: pgzSlideText
    visible: true
    opacity: 0
    property int textSize: gameBoard.height * 0.05
    property int duration: 750

    Rectangle {
        id: rectBackground
        width: theText.width
        height: theText.height

        color: "black"
        opacity: 0.5
        radius: 5
    }

    Text {
        id: theText
        font.pixelSize: textSize
        color: "white"
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        font.family: gameFont.name
        style: Text.Outline
        styleColor: "black"
        anchors.centerIn: rectBackground
    }

    function show(message, background) {
        rectBackground.visible = background;
        theText.text = message;
        animateMessage.restart();
    }

    SequentialAnimation {
        id: animateMessage


        ParallelAnimation {
            id: animateIn
            NumberAnimation { target: pgzSlideText; property: "x"; duration: 300; easing.type: Easing.Linear; from: parent.width + 10; to: parent.width / 2 - theText.width / 2 }
            NumberAnimation { target: pgzSlideText; property: "opacity"; duration: 300; easing.type: Easing.Linear; from: 0; to: 1 }
        }

        PauseAnimation { duration: pgzSlideText.duration }

        ParallelAnimation {
            id: animateOut
            NumberAnimation { target: pgzSlideText; property: "x"; duration: 300; easing.type: Easing.Linear; from: parent.width / 2 - theText.width / 2 ; to: (-width - 10) }
            NumberAnimation { target: pgzSlideText; property: "opacity"; duration: 300; easing.type: Easing.Linear; from: 1; to: 0 }
        }
    }
}
