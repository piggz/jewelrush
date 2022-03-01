import QtQuick 2.0
import QtMultimedia 5.0
//import QtAudioEngine 1.0

Rectangle {
    id: root
    focus: true

    property real optSfxVolume :0.4
    property real optMusicVolume: 0.7
    property bool optAdFreeBought: false

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

            if (gameBoard.gameState !== "PAUSED") {
                gameBoard.cmdStartNewGame();
            }
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

        onScoreloopClicked: {
            if (!GameCircle.showGameCircle()) {
                slideMessage2("GameCircle is not available\nPlease exit and connect to the\nInternet", true);
            }
        }

        onBuyClicked: {
            //IAP.purchaseItem("android.test.purchased");
            IAP.purchaseItem("uk.co.piggz.jewelrush.sku_noads");
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

    SettingsBoard {
        id: settingsBoard
        anchors.fill: parent

        onExitClicked: {
            settingsBoard.onScreen = false
        }
    }

    HiScoreBoard {
        id: hiScoreBoard
        anchors.fill: parent

        onExitClicked: {
            hiScoreBoard.onScreen = false
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

    //Advert timer
    Timer {
        id: tmrAd
        repeat: true
        running: false
        interval: 30000

        onTriggered : {
            Helper.showAdvert();
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
            event.accpeted = true;
        }

        if (event.key === Qt.Key_Back) {
            console.log ("Back Pressed");
            handleBackButton();
            event.accepted = true;
        }
    }

    Connections {
        target: Viewer
        onWindowStateChanged: {
            console.log("Window State Changed:", windowState);
            if (windowState === 1 && gameBoard.gameState === "RUNNING") { //minimized
                gameBoard.cmdPause();
            }
        }
    }

    Connections {
        target: App
        onApplicationStateChanged: {
            console.log("App state Changed:", state);
            if ((state === 0 || state === 1 || state === 2) && gameBoard.gameState === "RUNNING") { //suspended, hidden or inactive
                gameBoard.cmdPause();
            }
        }
    }

    FontLoader {
        id: gameFont
        source: "Floraless.ttf"
     }

    AudioEngine {
            id:audioengine

            AudioSample {
                name:"rotate"
                source: "sounds/rotate.wav"
            }
            AudioSample {
                name:"explosion"
                source: "sounds/explosion.wav"
            }
            AudioSample {
                name:"thud"
                source: "sounds/thud.wav"
            }
            AudioSample {
                name:"getready"
                source: "sounds/getready.wav"
            }
            AudioSample {
                name:"go"
                source: "sounds/go.wav"
            }
            AudioSample {
                name:"sad"
                source: "sounds/sad.wav"
            }

            Sound {
                name:"rotate"
                PlayVariation {
                    sample:"rotate"
                }
            }
            Sound {
                name:"explosion"
                PlayVariation {
                    sample:"explosion"
                }
            }
            Sound {
                name:"thud"
                PlayVariation {
                    sample:"thud"
                }
            }
            Sound {
                name:"getready"
                PlayVariation {
                    sample:"getready"
                }
            }
            Sound {
                name:"go"
                PlayVariation {
                    sample:"go"
                }
            }
            Sound {
                name:"sad"
                PlayVariation {
                    sample:"sad"
                }
            }
        }


    Audio {
        id: music
        source: "sounds/music.mp3"
        loops: Audio.Infinite
        volume: optMusicVolume
    }

    PGZSlideText {
        id: slideText
        anchors.verticalCenter: parent.verticalCenter;
        textSize: gameBoard.height * 0.03
        duration: 2500
    }

    function slideMessage(message) {
        slideText.show(message, false);
    }

    function slideMessage2(message, background) {
        slideText.show(message, background);
    }

    Component.onCompleted: {
        startup();
    }

    function startup() {
        loadSettings();
        checkPurchases();
    }

    function checkPurchases() {
        console.log("QML: checkPurchases");
        if (IAP.checkItemPurchased("uk.co.piggz.jewelrush.sku_noads")) {
            console.log("No Ads Purchased");
            optAdFreeBought = true;
        }

        saveSettings();
        tmrAd.running = !optAdFreeBought;
    }

    function quitGame() {
        saveSettings();
        ScoreModel.saveScores();
        Qt.quit();
    }

    function loadSettings(){
        optSfxVolume = Helper.getSetting("SFXVolume", 0.4);
        optMusicVolume = Helper.getSetting("MusicVolume", 0.7);
        optAdFreeBought = Helper.getBoolSetting("optAdFreeBought", false);
    }

    function saveSettings() {
        Helper.setSetting("SFXVolume", optSfxVolume);
        Helper.setSetting("MusicVolume", optMusicVolume);
        Helper.setSetting("optAdFreeBought", optAdFreeBought);
    }

    function handleBackButton() {
        if (gameBoard.onScreen) {
            gameBoard.backClicked();
            gameBoard.onScreen = false;
            return;
        }
        if (settingsBoard.onScreen) {
            settingsBoard.exitClicked();
            return;
        }
        if (infoBoard.onScreen) {
            infoBoard.exitClicked();
            return;
        }
        if (hiScoreBoard.onScreen) {
            hiScoreBoard.exitClicked();
            return;
        }

        quitGame();
    }

    Connections {
        target: IAP
        onItemPurchased: {
            console.log("Item Name:", itemName, " Purchase State: ", purchaseState);

            if (itemName === "uk.co.piggz.jewelrush.sku_noads" && purchaseState === 0) {
                slideMessage("Thank you!\nRe-open the game to remove ads");
                optAdFreeBought = true;
            } else if (purchaseState === 7) { //already purchased
                slideMessage("Thanks, but you dont need to\nbuy again!\nRe-open the game to remove ads");
                optAdFreeBought = true;
            } else {
                slideMessage("Removing ads failed");
                optAdFreeBought = false;
            }
            saveSettings();
        }
    }
}


