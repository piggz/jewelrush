import QtQuick 2.0
import QtQuick.Particles 2.0

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

    //Foreground particles
    BlockEmitter {
        jewel: jewel
        id: particles
        system: gameBoard.particleSystem
        group: color
        anchors.fill: parent
        enabled: false

    }

    AnimatedSprite {
        id: innerBomb
        visible: bomb
        anchors.fill: parent
        source: "pics/inner_bomb.png"
        frameCount: 12
        frameWidth: 256
        frameHeight: 128
        running: gameBoard.gameState === "RUNNING"
        opacity: 0.6
    }

    function jewelPositionX(indexX) {
        return (board.width * indexX / 6) + 2
    }

    function jewelPositionY(indexY) {
        return (board.height * indexY / 12) + 2
    }

    function explode(doe) {
        particles.enabled = true;
        exploding = true;
        particles.pulse(100);
        imgJewel.opacity = 0;
        destroyOnExplosion = doe
        if (doe){
            jewel.destroy(500);
        }
    }

}
