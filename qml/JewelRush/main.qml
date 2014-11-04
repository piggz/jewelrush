import QtQuick 2.0
import QtMultimedia 5.0

Rectangle {
    id: root
    width: 480
    height: 960

    focus: true

    //Intro Panel
    Intro {
        id: introWindow
        anchors.fill: parent
        onScreen: true
    }

    //Start Panel
    Start {
        id:startWindow
        anchors.fill: parent

        onStartClicked: {
            gameBoard.onScreen = true;
            gameBoard.cmdStartNewGame();
        }

        onSettingsClicked: {
            settingsBoard.onScreen = true;
        }

        onHiScoreClicked: {
            hiScoreBoard.onScreen = true;
        }

        onInfoClicked: {
            infoBoard.onScreen = true;
            infoBoard.inititalise();
        }

        onExitClicked: {
            quitGame();
        }
    }

    GameBoard {
        id: gameBoard
        onScreen: false
        anchors.fill: parent

        onExitClicked: {
            gameBoard.onScreen = false;
        }
    }

    Info {
        id: infoBoard
        onScreen: false
        anchors.fill: parent

        onExitClicked: {
            infoBoard.onScreen = false;
        }

    }

    //Hide intro window timer
    Timer {
        repeat: false
        interval: 3000
        running: true

        onTriggered: {
            introWindow.onScreen = false;
            startWindow.onScreen = true;
            startWindow.show();
            gameBoard.init();
            infoBoard.inititalise();
        }
    }

    Keys.onLeftPressed: {
        gameBoard.leftPressed();
    }

    Keys.onRightPressed: {
        gameBoard.rightPressed();
    }

    Keys.onSpacePressed: {
        gameBoard.spacePressed();
    }

    Keys.onDownPressed: {
        gameBoard.downPressed();
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_P) {
            if (gameBoard.gameState === "PAUSED") {
                gameBoard.cmdResume();
            } else {
                gameBoard.cmdPause();
            }
        }
    }

    function quitGame(){
        Qt.quit();
    }

    Connections {
        target: Viewer
        onWindowStateChanged: {
            console.log("State Changed:", windowState);
            if (state === 1) { //minimized
                gameBoard.cmdPause();
            }
        }
    }

    Connections {
        target: App
        onApplicationStateChanged: {
            console.log("App state Changed:", state);
            if (state === 2 || state === 4) { //inactive or suspended
                gameBoard.cmdPause();
            }
        }
    }

    PGZSoundEffect {
        id: sndExplosion
        source: "sounds/explosion.wav"
    }
    PGZSoundEffect {
        id: sndRotate
        source: "sounds/rotate.wav"
    }
    PGZSoundEffect {
        id: sndThud
        source: "sounds/thud.wav"
    }

    Audio {
        id: sndGetReady
        source: "sounds/getready.wav"

    }
    Audio {
        id: sndGo
        source: "sounds/go.wav"

    }
    Audio {
        id: sndSad
        source: "sounds/sad.wav"

    }

    FontLoader {
            id: gameFont
            source: "Floraless.ttf"
     }

    Audio {
        id: music
        source: "sounds/music.mp3"
        loops: Audio.Infinite
    }
}
