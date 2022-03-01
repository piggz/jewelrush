#include "pgz_platform.h"
#include <QtGui/QGuiApplication>
#include "qtquick2applicationviewer.h"
#include <QtQml>
#include "Helper.h"
#include "scoremodel.h"

#if defined(Q_OS_ANDROID)
    #include "gamecircleleaderboard.h"
    #ifdef AMAZON_DEVICE
        const char* ANDROID_MARKET = "AMAZON";
    #else
        const char* ANDROID_MARKET = "GOOGLE";
    #endif
#else
#include "nulliap.h"
#endif

#ifdef Q_OS_ANDROID
#include "androidiap.h"
#include <jni.h>

static JavaVM* jvm;

static JNINativeMethod methods[] = {
    {"itemPurchased", "(Ljava/lang/String;I)V", (void *)itemPurchased},
};

jint JNICALL JNI_OnLoad(JavaVM *vm, void *)
{
    JNIEnv *env;
    jvm = vm;
    if (vm->GetEnv(reinterpret_cast<void **>(&env), JNI_VERSION_1_4) != JNI_OK)
        return JNI_FALSE;

    jclass clazz = env->FindClass("uk/co/piggz/jewelrush/JewelRushActivity");
    if (env->RegisterNatives(clazz, methods, sizeof(methods) / sizeof(methods[0])) < 0)
        return JNI_FALSE;

    return JNI_VERSION_1_6;
}

#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationDomain("piggz.co.uk");

//work around harbour rules for config files
#if defined(MER_EDITION_SAILFISH)
    QCoreApplication::setOrganizationName("harbour-pgz-jewelrush");
    QCoreApplication::setApplicationName("harbour-pgz-jewelrush");
#else
    QCoreApplication::setOrganizationName("PGZ");
    QCoreApplication::setApplicationName("jewelrush");
#endif
    QtQuick2ApplicationViewer viewer;

    Helper helper;
    ScoreModel scoreModel;

    viewer.rootContext()->setContextProperty("Helper", &helper);
    viewer.rootContext()->setContextProperty("Viewer", &viewer);
    viewer.rootContext()->setContextProperty("App", &app);
    viewer.rootContext()->setContextProperty("ScoreModel", &scoreModel);

    pgzRegisterPlatform(viewer.rootContext());

#if defined(Q_OS_ANDROID)
    GameCircleLeaderboard gameCircle;
    viewer.rootContext()->setContextProperty("GameCircle", &gameCircle);
    viewer.rootContext()->setContextProperty("ANDROID_MARKET", ANDROID_MARKET);

    AndroidIAP &iap = AndroidIAP::instance();
    viewer.rootContext()->setContextProperty("IAP", &iap);
    viewer.setMainQmlFile(QStringLiteral("qml/JewelRush/main.qml"));
#elif defined(MER_EDITION_SAILFISH)
    NullIap iap;
    viewer.rootContext()->setContextProperty("IAP", &iap);
    viewer.setMainQmlFile(QStringLiteral("../share/harbour-pgz-jewelrush/qml/JewelRush/main.qml"));
#else
    NullIap iap;
    viewer.rootContext()->setContextProperty("IAP", &iap);
    viewer.setMainQmlFile(QStringLiteral("qml/JewelRush/main.qml"));
#endif

    viewer.setResizeMode(QQuickView::SizeRootObjectToView);

#if defined(PGZ_PLATFORM_DESKTOP)
    viewer.setWidth(480);
    viewer.setHeight(848);
#endif

#if defined(MER_EDITION_SAILFISH)
    viewer.showFullScreen();
#else
    viewer.show();
#endif
    return app.exec();
}
