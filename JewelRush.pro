TARGET=harbour-pgz-jewelrush

target.path = /usr/bin

# Add more folders to ship with the application, here
folder_01.source = qml/JewelRush
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

QT += svg

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

#Generic source files
SOURCES += main.cpp \
    Helper.cpp \
    scoremodel.cpp \
    nulliap.cpp

HEADERS += \
    Helper.h \
    pgz_platform.h \
    scoremodel.h \
    android/jni/includes/AchievementsClientInterface.h \
    android/jni/includes/AGSClientCommonInterface.h \
    android/jni/includes/GameCircleClientInterface.h \
    android/jni/includes/LeaderboardsClientInterface.h \
    android/jni/includes/PlayerClientInterface.h \
    android/jni/includes/WhispersyncClientInterface.h \
    nulliap.h

exists("/usr/lib/qt5/qml/Sailfish/Silica/SilicaGridView.qml") || exists("/usr/lib64/qt5/qml/Sailfish/Silica/SilicaGridView.qml"): {
    message(SailfishOS build)
    DEFINES += MER_EDITION_SAILFISH
    #Tablet
    #DEFINES += MER_PPI=330
    #Phone
    DEFINES += MER_PPI=245

    MER_EDITION = sailfish

    # QML files and folders
    #qml.files = *.qml pages cover main.qml

    # The .desktop file
    desktop.files = harbour-pgz-jewelrush.desktop

    # Please do not modify the following line.
    #include(../sailfishapplication/sailfishapplication.pri)

    OTHER_FILES =

    folder_01.target = ../share/harbour-pgz-jewelrush/qml
    folder_01.path = /usr/share/harbour-pgz-jewelrush
} else {
    folder_01.target = qml
}

#Android specific build
android {
    #Remoe this for google play version
    #DEFINES += AMAZON_DEVICE
    message("build for android")
    INCLUDEPATH += android/jni/includes/
    LIBS += -L$$PWD/android/jni/libs/ -lAmazonGamesJni
    QT += androidextras

    HEADERS += gamecircleleaderboard.h \
               androidiap.h
    SOURCES += gamecircleleaderboard.cpp \
               androidiap.cpp

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

    contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
        $$PWD/android/jni/libs/libAmazonGamesJni.so
    }
}

# Please do not modify the following two lines. Required for deployment.
include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    bar-descriptor.xml \
    android/AndroidManifest.xml \
    android/assets/api_key.txt \
    android/jni/libs/libAmazonGamesJni.so \
    android/src/uk/co/piggz/jewelrush/JewelRushActivity.java \
    android/src/uk/co/piggz/jewelrush/JewelRushApplication.java \
    android/res/anim/slide_down.xml \
    android/res/anim/slide_up.xml \
    android/src/uk/co/piggz/jewelrush/InAppConfig.java \
    android/ant.properties \
    rpm/harbour-pgz-jewelrush.yaml \
    harbour-pgz-jewelrush.desktop \
    harbour-pgz-jewelrush.png

DISTFILES += \
    rpm/harbour-pgz-jewelrush.spec

