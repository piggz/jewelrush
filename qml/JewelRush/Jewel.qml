import QtQuick 2.2

Item {
    id:jewel
    width: board.width / 6 - 2
    height: board.height / 12 - 2
    property int xpos: 0
    property int ypos: 0
    property bool falling: false
    property string color: "red"
    property bool bomb: false
    property bool exploding: false
    property bool destroyOnExplosion: true
    property bool moving: false

    x: jewelPositionX(xpos)
    y: jewelPositionY(ypos)

    Behavior on x {
        NumberAnimation { duration: 100 }
    }
    Behavior on y {
        NumberAnimation { duration: 100 }
    }
/*
    onXChanged: {
        moving = true;
        moveTimer.restart();
    }
    onYChanged: {
        moving = true;
        moveTimer.restart();
    }

    Timer {
        id: moveTimer
        repeat: false
        interval: 200
        onTriggered: {
            moving = false;
        }
    }
*/

    /*
    XAnimator{
        target: jewel
        duration: 100
        to: jewelPositionX(jewel.xpos)
        from: jewel.x
        running: true
    }

    YAnimator {
        target: jewel
        duration: 100
        to: jewelPositionY(jewel.ypos)
        from: jewel.y
        running: true
    }*/



    function reset() {
        exploding = false;
        imgJewel.opacity = 1;
    }

    Image {
        id: imgJewel
        anchors.fill: parent
        source: "pics/" + (bomb ? "bomb_" : "jewel_") + color + ".svg"
        fillMode: Image.Stretch
        smooth: true
        Behavior on opacity {
            NumberAnimation {duration: 500}
        }
    }

    Explosion {
        id: myExplosion
        anchors.centerIn: parent
        width: parent.width * 3
        height: width
        color: jewel.color

        onComplete: {
            if (destroyOnExplosion) {
                jewel.destroy();
            }
        }
    }

    AnimatedSprite {
        id: innerBomb
        visible: bomb
        anchors.fill: parent
        source: "pics/inner_bomb.png"
        frameCount: 16
        frameSync: false
        frameWidth: 256
        frameHeight: 128
        frameRate: 15
        loops: AnimatedSprite.Infinite
        running: true
        opacity: 0.6

        onCurrentFrameChanged: {
            if (currentFrame === 29) {
                reverse = true;
            }
            if (currentFrame === 0) {
                reverse = false;
            }
        }
    }

    function jewelPositionX(indexX) {
        return (board.width * indexX / 6) + 2
    }

    function jewelPositionY(indexY) {
        return (board.height * indexY / 12) + 2
    }

    function explode(doe) {
        exploding = true;
        myExplosion.play();
        imgJewel.opacity = 0;
        destroyOnExplosion = doe
    }

}
