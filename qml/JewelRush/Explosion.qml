import QtQuick 2.0

Item {
    id:explosion
    width: 44
    height: 32
    visible: false

    signal complete();

    property string color: ""

    function play() {
        explosion.visible = true;
        sprite.start();

    }

    AnimatedSprite {
        id: sprite
        anchors.fill: parent
        source: "pics/explosion_" + color + ".png"
        frameCount: 16
        frameSync: false
        frameWidth: 256
        frameHeight: 256
        frameRate: 20
        loops: 1
        running: false
        visible: parent.visible

        onRunningChanged: {
            if (!running) {
                explosion.visible = false;
                complete();
            }
        }
        onCurrentFrameChanged: {
            if (currentFrame === 15) {
                explosion.visible = false;
            }
        }

    }
}
