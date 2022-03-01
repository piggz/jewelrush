import QtQuick 2.0
//import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import "logic.js" as Logic

Rectangle {

    signal exitClicked();
    property bool onScreen: false;
    opacity: onScreen ? 1 : 0
    visible: opacity > 0.2;
    Behavior on opacity {
        NumberAnimation {duration: 200}
    }

    Image {
        id: background
        source: "pics/back.png"
        smooth: true
        z: 0
        fillMode: Image.Stretch
        anchors.fill: parent
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
        id: board
        clip: true
        anchors.top: boardBack.top
        anchors.bottom: boardBack.bottom
        anchors.left: boardBack.left
        anchors.right: boardBack.right

        //Jewels used for tutorial
        Jewel {
            id: jewel1
            color: "red"
            xpos: 2
            ypos: -1
        }

        Jewel {
            id: jewel2
            color: "green"
            xpos: 2
            ypos: -1
        }
        Jewel {
            id: jewel3
            color: "yellow"
            xpos: 2
            ypos: -1
        }
        Jewel {
            id: jewel4
            color: "red"
            xpos: 2
            ypos: -1
        }
        Jewel {
            id: jewel5
            color: "blue"
            xpos: 2
            ypos: -1
        }
        Jewel {
            id: jewel6
            color: "red"
            xpos: 2
            ypos: -1
            bomb: true
        }
    }

    MouseArea {
        anchors.fill: board

        onClicked: {
            txtInfo.opacity = 0;
            tutorialAnimation.start();
        }
    }

    Text {
        id: txtInfo
        anchors.fill: board

        font.family: gameFont.name
        color: "white"
        font.pixelSize: gameBoard.height * 0.02
        anchors.margins: 20
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        Behavior on opacity {
            NumberAnimation {duration: 400}
        }

        text: "Jewel Rush\n\nObjective: Get the highst score possible without letting the jewels fill to the top of the screen\n\n\
Controls:\n\
Tap to rotate\n\
Swipe left to move left\n\
Swipe right to move right\n\
Swipe down to drop\n\n\
Blow up adjoining jewels of the same color with a bomb block\n\n\
Contact:\nhttp://www.piggz.co.uk\nadam@piggz.co.uk\n\n
Tap to view tutorial
"
    }

    CloseButton {
        id: closebutton

        onClicked: {
            exitClicked();
        }
    }

    PGZSlideText {
        id: slideText
        anchors.verticalCenter: parent.verticalCenter;
        textSize: gameBoard.height * 0.03
        duration: 2000
    }

    function slideMessage(message) {
        slideText.show(message, false);
    }

    function inititalise() {
        closebutton.init();
        txtInfo.opacity = 1;
        tutorialAnimation.stop();
        jewel1.xpos = 2
        jewel1.ypos = -1
        jewel2.xpos = 2
        jewel2.ypos = -1
        jewel3.xpos = 2
        jewel3.ypos = -1
        jewel4.xpos = 2
        jewel4.ypos = -1
        jewel5.xpos = 2
        jewel5.ypos = -1
        jewel6.xpos = 2
        jewel6.ypos = -1

        jewel1.reset();
        jewel2.reset();
        jewel3.reset();
        jewel4.reset();
        jewel5.reset();
        jewel6.reset();
        jewel6.visible = true;
    }

    SequentialAnimation {
        id: tutorialAnimation
        ScriptAction { script: slideMessage("Jewels drop from the\ntop of the screen") }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: jewel1.ypos = 0 }
        PauseAnimation { duration: 900 }
        ScriptAction { script: jewel1.ypos = 1 }
        ScriptAction { script: jewel2.ypos = 0 }
        PauseAnimation { duration: 900 }
        ScriptAction { script: jewel1.ypos = 2 }
        ScriptAction { script: jewel2.ypos = 1 }
        PauseAnimation { duration: 900 }
        ScriptAction { script: jewel1.ypos = 3 }
        ScriptAction { script: jewel2.ypos = 2 }
        PauseAnimation { duration: 900 }
        ScriptAction { script: jewel1.ypos = 4 }
        ScriptAction { script: jewel2.ypos = 3 }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: slideMessage("Tap the screen to\nrotate the jewels") }
        PauseAnimation { duration: 2000 }
        ScriptAction { script: jewel2.xpos = 3 }
        ScriptAction { script: jewel2.ypos = 4 }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: jewel2.xpos = 2 }
        ScriptAction { script: jewel2.ypos = 5 }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: jewel2.xpos = 1 }
        ScriptAction { script: jewel2.ypos = 4 }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: slideMessage("Swipe left to\nmove jewels left") }
        PauseAnimation { duration: 2000 }
        ScriptAction { script: jewel1.xpos-- }
        ScriptAction { script: jewel2.xpos-- }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: slideMessage("Swipe right to\nmove jewels right") }
        PauseAnimation { duration: 2000 }
        ScriptAction { script: jewel1.xpos++ }
        ScriptAction { script: jewel2.xpos++ }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: jewel1.xpos++ }
        ScriptAction { script: jewel2.xpos++ }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: slideMessage("Swipe down to\ndrop the jewels") }
        PauseAnimation { duration: 2000 }
        ScriptAction { script: jewel1.ypos = 11 }
        ScriptAction { script: jewel2.ypos = 11 }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: slideMessage("New Jewels will drop") }
        PauseAnimation { duration: 2000 }
        ScriptAction { script: jewel3.ypos = 0 }
        PauseAnimation { duration: 900 }
        ScriptAction { script: jewel3.ypos = 1 }
        ScriptAction { script: jewel4.ypos = 0 }
        PauseAnimation { duration: 900 }
        ScriptAction { script: jewel3.ypos = 2 }
        ScriptAction { script: jewel4.ypos = 1 }
        PauseAnimation { duration: 900 }
        ScriptAction { script: jewel3.ypos = 3 }
        ScriptAction { script: jewel4.ypos = 2 }
        PauseAnimation { duration: 900 }
        ScriptAction { script: jewel3.ypos = 4 }
        ScriptAction { script: jewel4.ypos = 3 }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: slideMessage("Try to line up\nmatching colors") }
        PauseAnimation { duration: 2000 }
        ScriptAction { script: jewel4.xpos = 3 }
        ScriptAction { script: jewel4.ypos = 4 }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: jewel4.xpos = 2 }
        ScriptAction { script: jewel4.ypos = 5 }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: jewel4.xpos = 1 }
        ScriptAction { script: jewel4.ypos = 4 }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: jewel3.xpos++ }
        ScriptAction { script: jewel4.xpos++ }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: jewel3.xpos++ }
        ScriptAction { script: jewel4.xpos++ }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: jewel3.ypos = 11 }
        ScriptAction { script: jewel4.ypos = 10 }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: jewel5.ypos = 0 }
        PauseAnimation { duration: 900 }
        ScriptAction { script: jewel5.ypos = 1 }
        ScriptAction { script: jewel6.ypos = 0 }
        PauseAnimation { duration: 900 }
        ScriptAction { script: jewel5.ypos = 2 }
        ScriptAction { script: jewel6.ypos = 1 }
        PauseAnimation { duration: 900 }
        ScriptAction { script: jewel5.ypos = 3 }
        ScriptAction { script: jewel6.ypos = 2 }
        PauseAnimation { duration: 900 }
        ScriptAction { script: jewel5.ypos = 4 }
        ScriptAction { script: jewel6.ypos = 3 }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: slideMessage("A jewel bomb will\ndestroy adjoining\njewels the same color") }
        PauseAnimation { duration: 2000 }
        ScriptAction { script: jewel6.xpos = 3 }
        ScriptAction { script: jewel6.ypos = 4 }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: jewel5.ypos = 10 }
        ScriptAction { script: jewel6.ypos = 9 }
        PauseAnimation { duration: 500 }
        ScriptAction { script: jewel6.explode(false) }
        ScriptAction { script: jewel4.explode(false) }
        ScriptAction { script: jewel1.explode(false) }
        PauseAnimation { duration: 500 }
        ScriptAction { script: jewel6.visible = false }
        ScriptAction { script: slideMessage("A bigger explosion\ngets more points!") }
        PauseAnimation { duration: 2000 }
        ScriptAction { script: slideMessage("The game is over if\nthe jewels reach the\ntop of the screen") }
        PauseAnimation { duration: 2000 }
        PauseAnimation { duration: 2000 }
        ScriptAction { script: inititalise() }

    }

}
