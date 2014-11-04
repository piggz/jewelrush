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

    Timer {
        id: starttimer3
        repeat:  false
        interval: 1000
        running: false
        onTriggered: {
            animButtonShow.start();
        }
    }

    CloseButton {
        id: closebutton

        onClicked: {
            exitClicked();
        }
    }

    Image {
        id: imgLogo
        source: "pics/logo.png"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 5
        width: parent.width - 40
        height: width * 0.6
    }

    Item {
        id: buttonArea
        anchors.top: imgLogo.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        property int buttonHeight: (height - 30*children.length) / children.length


        //Start button
        ImageButton {
            id: buttonStart
            height: parent.buttonHeight
            opacity: 0

            anchors.left: parent.left
            anchors.leftMargin:80
            anchors.top: parent.top
            anchors.topMargin: 0

            image: "pics/start.png"
            text: "Play"
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
            anchors.top: buttonStart.bottom
            anchors.topMargin: 30

            image: "pics/options.png"
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
            anchors.top: buttonOptions.bottom
            anchors.topMargin: 30

            image: "pics/hiscore.png"
            text: "Scores"
            highlighed: selectedItem === 3

            onClicked: {
                hiScoreClicked();
            }
        }

        //Scoreloop button
        ImageButton {
            id: buttonScoreLoop
            height: parent.buttonHeight
            opacity: 0

            anchors.left: buttonStart.left
            anchors.top: buttonHiScore.bottom
            anchors.topMargin: 30

            image: "pics/scoreloop.png"
            text: "Scoreloop"
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
            anchors.top: buttonScoreLoop.bottom
            anchors.topMargin: 30

            image: "pics/info.png"
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
            anchors.top: buttonInfo.bottom
            anchors.topMargin: 30

            image:"pics/play_store.png"
            text: "More Apps"
            highlighed: selectedItem === 7;

            onClicked: {
                if (GOOGLE_IAP) {
                    Qt.openUrlExternally("market://search?q=pub:Adam Pigg");
                } else {
                    Qt.openUrlExternally("http://www.amazon.com/gp/mas/dl/android?p=uk.co.piggz.pgz_spaceinvaders&showAll=1");
                }
            }
        }

        //Buy button
        ImageButton {
            id: buttonBuy
            height: parent.buttonHeight
            opacity: 0
            //visible: !optFullGameBought


            anchors.left: buttonStart.left
            anchors.top: buttonPlay.bottom
            anchors.topMargin: 30

            image: "pics/buy_full_game.png"
            text: "Unlock"
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
        NumberAnimation { target: buttonScoreLoop; property: "opacity"; easing.type: Easing.Linear; to: 1; duration: 150 }
        NumberAnimation { target: buttonInfo; property: "opacity"; easing.type: Easing.Linear; to: 1; duration: 150 }
        NumberAnimation { target: buttonPlay; property: "opacity"; easing.type: Easing.Linear; to: 1; duration: 150 }
        NumberAnimation { target: buttonBuy; property: "opacity"; easing.type: Easing.Linear; to: 1; duration: 150 }

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

}
