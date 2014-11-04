#include <QtGui/QGuiApplication>
#include "qtquick2applicationviewer.h"
#include <QtQml>
#include "Helper.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QtQuick2ApplicationViewer viewer;

    Helper helper;

    viewer.rootContext()->setContextProperty("Helper", &helper);
    viewer.rootContext()->setContextProperty("Viewer", &viewer);
    viewer.rootContext()->setContextProperty("App", &app);

    viewer.setMainQmlFile(QStringLiteral("qml/JewelRush/main.qml"));
    viewer.setResizeMode(QQuickView::SizeRootObjectToView);
    viewer.showExpanded();

    return app.exec();
}
