# Add more folders to ship with the application, here
folder_01.source = qml/JewelRush
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

QT += svg \
      multimedia

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    Helper.cpp

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.
include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()

HEADERS += \
    Helper.h

OTHER_FILES += \
    bar-descriptor.xml \
    android/AndroidManifest.xml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
