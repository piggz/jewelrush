import QtQuick 2.0

Item {
    property real value
    property bool highlighted: false

    signal sliderChanged(real new_value)

    Rectangle {
        id: outer
        anchors.fill: parent
        border.color: "white"
        color: "black"
        border.width: 3

        Rectangle {
            id: inner
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: parent.width * value
            color: highlighted? "#ff9900" : "white"
        }
    }
    MouseArea {
        anchors.fill: outer

        onPositionChanged:  {
            value = mouse.x / outer.width;
            if (value > 1) value = 1;
            if (value < 0) value = 0;
            sliderChanged(value);
        }
    }
}


