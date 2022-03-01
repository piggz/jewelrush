import QtQuick 2.0

Rectangle {
    id: startWindow

    signal startClicked
    signal exitClicked
    signal settingsClicked
    signal hiScoreClicked
    signal infoClicked
    signal scoreloopClicked
    signal buyClicked

    property int selectedItem: 0
    property bool adsEnabled: true

    property bool onScreen: false;
    opacity: onScreen ? 1 : 0
    visible: opacity > 0;
    Behavior on opacity {
        NumberAnimation {duration: 400}
    }

    Image {
        id: background
        source: "pics/back.png"
        smooth: true
        z: 0
        fillMode: Image.Stretch
        anchors.fill: parent
    }

    function show() {
        animButtonShow.start();
        closebutton.init();
        //starttimer3.start();
    }

/*    Timer {
        id: starttimer3
        repeat:  false
        interval: 1000
        running: false
        onTriggered: {
            console.log("Timer start");

            animButtonShow.start();
        }
    }
*/
    CloseButton {
        id: closebutton

        onClicked: {
            exitClicked();
        }
    }

    Image {
        id: imgLogo
        source: "pics/logo2.png"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 5
        fillMode: Image.PreserveAspectFit
        width: parent.width
        height: parent.height / 4
    }

    Column {
        id: buttonArea
        anchors.top: imgLogo.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        property int buttonHeight: (height - ((height * 0.04) * (children.length + 3))) / children.length + 2
        spacing: height * 0.04

        //Start button
        ImageButton {
            id: buttonStart
            height: parent.buttonHeight
            opacity: 0

            anchors.left: parent.left
            anchors.leftMargin:80

            image: "pics/btnPlay.png"
            text: gameBoard.gameState === "PAUSED" ? "Resume" : "Play"
            highlighed: selectedItem === 1

            onClicked: {
                startClicked();
            }
        }



        //Options button
        ImageButton {
            id: buttonOptions
            height: parent.buttonHeight
            opacity: 0
            anchors.left: buttonStart.left

            image: "pics/btnSettings.png"
            text: "Options"
            highlighed: selectedItem === 2

            onClicked: {
                settingsClicked();
            }
        }


        //HiScore button
        ImageButton {
            id: buttonHiScore
            height: parent.buttonHeight
            opacity: 0
            anchors.left: buttonStart.left

            image: "pics/btnScores.png"
            text: "Scores"
            highlighed: selectedItem === 3

            onClicked: {
                hiScoreClicked();
            }
        }

        //Gamecircle button
        ImageButton {
            id: buttonScoreLoop
            height: parent.buttonHeight
            opacity: 0
            visible: PlatformID === 4
            anchors.left: buttonStart.left

            image: "pics/btnGameCircle.png"
            text: "Gamecircle"
            highlighed: selectedItem === 4

            onClicked: {
                scoreloopClicked();
            }
        }

        //Info button
        ImageButton {
            id: buttonInfo
            height: parent.buttonHeight
            opacity: 0
            anchors.left: buttonStart.left


            image: "pics/btnInfo.png"
            text: "Info"
            highlighed: selectedItem === 5;

            onClicked: {
                infoClicked();
            }
        }

        //Play button
        ImageButton {
            id: buttonPlay
            height: parent.buttonHeight
            opacity: 0
            anchors.left: buttonStart.left
            visible: PlatformID === 4 || PlatformID === 7
            image: imageForStoreButton()
            text: "More Apps"
            highlighed: selectedItem === 7;

            onClicked: {
                openStore();
            }
        }

        //Buy button
        ImageButton {
            id: buttonBuy
            height: parent.buttonHeight
            opacity: 0
            visible: PlatformID === 4 && !optAdFreeBought

            anchors.left: buttonStart.left

            image: "pics/btnBuy.png"
            text: "Donate/Go Ad Free!"
            highlighed: selectedItem === 6;

            onClicked: {
                buyClicked();
            }
        }
    }

    Image {
        source: "pics/watch.png"
        y: buttonInfo.y + buttonInfo.height / 2 + buttonArea.y - height
        x: buttonInfo.x + buttonInfo.width + 40 + buttonArea.x
        width: parent.width - buttonInfo.x - buttonInfo.width - 50
        fillMode: Image.PreserveAspectFit
    }


    //Show the buttons in sequence
    SequentialAnimation {
        id: animButtonShow
        NumberAnimation { target: buttonStart; property: "opacity"; easing.type: Easing.Linear; to: 1; duration: 150 }
        NumberAnimation { target: buttonOptions; property: "opacity"; easing.type: Easing.Linear; to: 1; duration: 150 }
        NumberAnimation { target: buttonHiScore; property: "opacity"; easing.type: Easing.Linear; to: 1; duration: 150 }
        NumberAnimation { target: buttonScoreLoop; property: "opacity"; easing.type: Easing.Linear; to: 1; duration: buttonScoreLoop.visible ? 150 : 0 }
        NumberAnimation { target: buttonInfo; property: "opacity"; easing.type: Easing.Linear; to: 1; duration: 150 }
        NumberAnimation { target: buttonPlay; property: "opacity"; easing.type: Easing.Linear; to: 1; duration: buttonPlay.visible ? 150 : 0  }
        NumberAnimation { target: buttonBuy; property: "opacity"; easing.type: Easing.Linear; to: 1; duration: buttonBuy.visible ? 150 : 0  }
        ScriptAction { script: finalStartup() }
    }

    function rightPressed() {
        selectedItem++;
        if (selectedItem > 5) {
            selectedItem = 1;
        }
    }

    function leftPressed() {
        selectedItem--;
        if (selectedItem < 1) {
            selectedItem = 5;
        }
    }

    function firePressed() {
        switch(selectedItem) {
        case 1:
            startClicked();
            break;
        case 2:
            settingsClicked();
            break;
        case 3:
            hiScoreClicked();
            break;
        case 4:
            scoreloopClicked();
            break;
        case 5:
            infoClicked();
            break;
        }
    }

    function imageForStoreButton() {
        if (PlatformID === 4) {
            return ANDROID_MARKET === "GOOGLE" ? "pics/btnPlayStore.png" : "pics/btnAmazonApps.png"
        } else if (PlatformID === 7) {
            return "pics/btnBlackberryWorld.png"
        }
        return "";
    }

    function openStore() {
        if (PlatformID === 4) {
            if (ANDROID_MARKET === "GOOGLE") {
                Qt.openUrlExternally("market://search?q=pub:Adam Pigg");
            } else {
                Qt.openUrlExternally("amzn://apps/android?s=uk.co.piggz&showAll=1");
            }
        } else if (PlatformID === 7) {
            Qt.openUrlExternally("https://appworld.blackberry.com/webstore/vendor/35052/");
        }
    }

    function finalStartup()
    {
        //Submit the highest score if connected to GameCircle
        if (PlatformID === 4) {
            if (GameCircle.agsReady()){
                GameCircle.submitScore("jewelrush_leaderboard_0", gameBoard.score);
            }
        }
        console.log(gameBoard.gameState);
    }

}
