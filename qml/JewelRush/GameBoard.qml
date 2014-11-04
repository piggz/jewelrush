import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import "logic.js" as Logic

Rectangle {

    property string gameState: "STOPPED"

    property int score: 0
    property int level: 1

    signal exitClicked();
    property bool onScreen: false;
    opacity: onScreen ? 1 : 0
    visible: opacity > 0;

    function init() {
        closebutton.init();
    }

    Behavior on opacity {
        NumberAnimation {duration: 400}
    }

    Behavior on score {
        NumberAnimation {duration: 500}
    }

    onLevelChanged: {
        slideMessage("Level " + level);
    }

    onScoreChanged: {
        level = Math.floor(score / 100) + 1;
    }

    Image {
        id: background
        source: "pics/back.png"
        smooth: true
        z: 0
        fillMode: Image.Stretch
        anchors.fill: parent
    }

    Text {
        id: txtScore
        text: "Score: " + score
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        font.pixelSize: gameBoard.height * 0.02;
        color: "white"
        font.bold: true
        font.family: gameFont.name
        style: Text.Outline
        styleColor: "black"
    }

    Text {
        id: txtLevel
        text: "Level: " + level
        anchors.top: txtScore.bottom
        anchors.left: parent.left
        anchors.margins: 10
        font.pixelSize: gameBoard.height * 0.02;
        color: "white"
        font.bold: true
        font.family: gameFont.name
        style: Text.Outline
        styleColor: "black"
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
        height: parent.height - txtLevel.y - txtLevel.height - 40
        anchors.margins: 20
    }

    Item {
        id: board
        clip: true
        anchors.top: boardBack.top
        anchors.bottom: boardBack.bottom
        anchors.left: boardBack.left
        anchors.right: boardBack.right
    }

    Desaturate {
        id: desaturate
        anchors.fill: board
        source: board
        desaturation: 0

        Behavior on desaturation {
            NumberAnimation { duration: 500 }
        }
    }

    SwipeArea {
        anchors.fill: board

        onSwipe: {
            if (direction === "left") {
                Logic.scheduleLeftEvent();
            } else if (direction === "right") {
                Logic.scheduleRightEvent();
            } else if (direction === "down") {
                Logic.scheduleDownEvent();
            }
        }

        onClick: {
            if (gameState === "PAUSED") {
                Logic.cmdResume();
            } else {
                Logic.scheduleRotateEvent();
            }
        }
    }

    CloseButton {
        id: closebutton
        width: Helper.mmToPixels(7);

        onClicked: {
            Logic.cmdDead();
            exitClicked();
        }
    }

    Timer {
        id: jewelTick

        interval: (900) - ((level - 1) * 20)
        running: true
        repeat: true
        onTriggered: {
            Logic.scheduleJewelEvent();
        }
    }

    Timer {
        id: mainEvent

        interval: 50
        running: true
        repeat: true

        onTriggered: {
            Logic.mainEvent();
        }
    }

    Explosion {
        visible: true
    }

    Component.onCompleted: {
        Logic.initialise();
    }

    function leftPressed()
    {
        Logic.scheduleLeftEvent();
    }

    function rightPressed()
    {
        Logic.scheduleRightEvent();
    }

    function spacePressed()
    {
        Logic.scheduleRotateEvent();
    }

    function downPressed()
    {
        Logic.scheduleDownEvent();
    }

    function cmdStartNewGame()
    {
        Logic.cmdStartNewGame();
    }

    function cmdPause() {
        Logic.cmdPause();
    }

    function cmdResume() {
        Logic.cmdResume();
    }

    SequentialAnimation {
        id: startingAnimation
         PauseAnimation { duration: 250 }
         ScriptAction { script: {slideMessage("Get Ready..."); sndGetReady.play();} }
         PauseAnimation { duration: 1750 }
         ScriptAction { script: {slideMessage("Go!"); sndGo.play();}}

         onStopped: Logic.cmdRunning();
    }

    PGZSlideText {
        id: slideText
        anchors.verticalCenter: parent.verticalCenter;
    }

    function slideMessage(message) {
        slideText.show(message);
    }
}


