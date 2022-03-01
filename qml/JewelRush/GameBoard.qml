import QtQuick 2.0
//import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Particles 2.0

import "logic.js" as Logic

Rectangle {
    signal exitClicked();

    property string gameState: "STOPPED"
    property int score: 0
    property int level: 1
    property string nextJewel1Color: "red"
    property bool nextJewel1Type;
    property string nextJewel2Color: "green"
    property bool nextJewel2Type;
    property alias particleSystem: particleSystem;
    property bool onScreen: false;

    property int mainTicks: 0
    property int jewelEvent: 30

    opacity: onScreen ? 1 : 0
    visible: opacity > 0.2;

    function init() {
        closebutton.init();
    }

    Behavior on opacity {
        NumberAnimation {duration: 200}
    }

    Behavior on score {
        NumberAnimation {duration: 500}
    }

    onLevelChanged: {
        slideMessage("Level " + level);
    }

    onScoreChanged: {
        var l = Math.floor(score / 100) + 1;

        if (l > 20) {
            l = 20;
        }
        level = l;
        jewelEvent = 30 - (level - 1);
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

    Text {
        id: txtNext
        text: "Next:"
        anchors.top: txtLevel.bottom
        anchors.left: parent.left
        anchors.margins: 10
        font.pixelSize: gameBoard.height * 0.02;
        color: "white"
        font.bold: true
        font.family: gameFont.name
        style: Text.Outline
        styleColor: "black"
    }

    Jewel {
        id: nextJewel2
        color: nextJewel2Color
        bomb: nextJewel2Type
        anchors.top: txtNext.bottom
        anchors.topMargin: 10
    }
    Jewel {
        id: nextJewel1
        color: nextJewel1Color
        bomb: nextJewel1Type
        anchors.top: nextJewel2.bottom
        anchors.topMargin: 0
    }

    Rectangle {
        id: boardBack
        property bool widthConstraint: false
        border.color: "white"
        border.width:5

        color: "#000000"
        opacity: 0.6
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        //width: widthConstraint ? ((parent.width / 8) - 2) * 6 : height/2
        //height: widthConstraint ? width * 2 : parent.height - txtLevel.y - txtLevel.height - 100
        anchors.margins: 100
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
        }
    }

    //Pause/Resume Button
    Image {
        width: closebutton.width
        height: closebutton.height
        anchors.top: closebutton.bottom
        anchors.left: closebutton.left
        anchors.topMargin: 15
        source: gameBoard.gameState === "PAUSED" ? "pics/btnRestart.png" : "pics/btnPause.png"
        MouseArea {
            anchors.fill: parent

            onClicked:  {
                if (gameBoard.gameState === "PAUSED") {
                    Logic.cmdResume();
                } else {
                    Logic.cmdPause();
                }
            }
        }
    }

    Timer {
        id: mainEvent

        interval: 30
        running: gameState === "RUNNING"
        repeat: true

        onTriggered: {
            Logic.mainEvent();
        }
    }

    Component.onCompleted: {
        Logic.initialise();
    }

    onWidthChanged: {
        resize();
    }

    onHeightChanged: {
        resize();
    }

    function resize()
    {
        if (width > 0 && height > 0) {
            var widthConstraint = ((height - txtLevel.y - txtLevel.height - 100) / 2) > (((width / 8) - 2) * 6);
            boardBack.width = widthConstraint ? ((width / 8) - 2) * 6 : (height - txtLevel.y - txtLevel.height - 100)/2
            boardBack.height = widthConstraint ? boardBack.width * 2 : height - txtLevel.y - txtLevel.height - 100

            console.log(widthConstraint, width, height, boardBack.width, boardBack.height)
        }
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

    function backClicked() {
        Logic.cmdPause();

    }

    function dead() {
        ScoreModel.addScore(score, "default", "default", 1, level, nowString());
        if (PlatformID === 4) {
            GameCircle.submitScore("jewelrush_leaderboard_0", score);
        }
        deadAnimation.start();
    }

    SequentialAnimation {
        id: startingAnimation
        PauseAnimation { duration: 250 }
        ScriptAction { script: {slideMessage("Get Ready..."); Logic.playSoundEffect("getready");} }
        PauseAnimation { duration: 1750 }
        ScriptAction { script: {slideMessage("Go!"); Logic.playSoundEffect("go");}}
        onStopped: Logic.cmdRunning();
    }

    SequentialAnimation {
        id: deadAnimation
        PauseAnimation { duration: 3000 }
        ScriptAction { script: { exitClicked(); gameBoard.level = 1; } }
    }

    PGZSlideText {
        id: slideText
        anchors.verticalCenter: parent.verticalCenter;
    }

    ParticleSystem {
        id: particleSystem;
        anchors.fill: parent
        z: 5
        running: gameState === "RUNNING"

        ImageParticle {
            groups: ["yellow"]
            system: particleSystem
            color: Qt.darker("yellow");//Actually want desaturated...
            source: "pics/particle-brick.png"
            colorVariation: 0.4
            alpha: 0.1
        }
        ImageParticle {
            groups: ["red"]
            system: particleSystem
            color: Qt.darker("red");//Actually want desaturated...
            source: "pics/particle-brick.png"
            colorVariation: 0.4
            alpha: 0.1
        }
        ImageParticle {
            groups: ["green"]
            system: particleSystem
            color: Qt.darker("green");//Actually want desaturated...
            source: "pics/particle-brick.png"
            colorVariation: 0.4
            alpha: 0.1
        }
        ImageParticle {
            groups: ["blue"]
            system: particleSystem
            color: Qt.darker("blue");//Actually want desaturated...
            source: "pics/particle-brick.png"
            colorVariation: 0.4
            alpha: 0.1
        }
    }

    function slideMessage(message) {
        slideText.show(message, false);
    }

    function nowString()
    {
        var d = new Date();
        var curr_date = pad(d.getDate(), 2);
        var curr_month = pad(d.getMonth() + 1, 2);
        var curr_year = d.getFullYear();
        return curr_year + "-" + curr_month + "-" + curr_date;
    }

    function pad(num, size) {
        var s = num+"";
        while (s.length < size) s = "0" + s;
        return s;
    }
}


