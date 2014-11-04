import QtQuick 2.0

//Start button
Item {
    id: imgButton
    property string image: ""
    property string text: ""
    property bool highlighed: false;

    signal clicked
    width: childrenRect.width

    Rectangle {
        id: rectBackground
        z: 1
        height: parent.height
        radius: height/2
        border.width: 5
        width: txt.width + height + radius
        opacity: 0.5
        MouseArea {
            id: txtStartArea
            anchors.fill: parent
            onClicked: {
                imgButton.clicked();
            }

            onPressed: {
                rectBackground.opacity = 1;
            }

            onReleased: {
                rectBackground.opacity = 0.5;
            }
        }
    }

    Image {
        z:2
        height: parent.height
        width: height
        source: image

        Rectangle {
            anchors.centerIn: parent
            width: 30
            height: 30
            radius: 15
            color: "#ff9900"
            visible: highlighed
        }
        MouseArea {
            id: buttonStartArea
            anchors.fill: parent
            onClicked: {
                imgButton.clicked();
            }

            onPressed: {
                rectBackground.opacity = 1;
            }

            onReleased: {
                rectBackground.opacity = 0.5;
            }
        }
    }

    Text {
        id: txt
        z: 3
        x: imgButton.height + 10
        anchors.verticalCenter: rectBackground.verticalCenter
        font.pixelSize: parent.height - 40
        text: imgButton.text
    }


}
