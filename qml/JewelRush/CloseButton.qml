import QtQuick 2.0

Image {

    signal clicked
    property int mmwidth: 7

    id: closebutton

    source: "pics/x.svg"
    height: width

    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.top: parent.top
    anchors.topMargin: 0

    fillMode: Image.PreserveAspectFit
    smooth: true

    MouseArea {
        id: closearea
        anchors.fill: parent
    }

    Component.onCompleted: startupFunction();

    function startupFunction() {
        closearea.clicked.connect(clicked)
    }

    function init() {
        width = Helper.mmToPixels(mmwidth);
    }
}
