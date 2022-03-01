#ifndef PGZ_PLATFORM_H
#define PGZ_PLATFORM_H

#include <QtQml/QQmlContext>

#if defined(Q_OS_SYMBIAN)
    const int platformId = 0;
    const char *platformString = "SYMBIAN";
#elif defined(Q_WS_MAEMO_5)
    const int platformId = 1;
    const char *platformString = "MAEMO5";
#elif defined(QT_SIMULATOR)
    const int platformId = 2;
    const char *platformString = "SIMULATOR";
#elif defined(MEEGO_EDITION_HARMATTAN)
    const int platformId = 3;
    const char *platformString = "HARMATTAN";
#elif defined(Q_OS_ANDROID)
    const int platformId = 4;
    const char *platformString = "ANDROID";
#elif defined(Q_OS_PLAYBOOK)
    const int platformId = 6;
    const char *platformString = "BBPLAYBOOK";
#elif defined(Q_OS_BLACKBERRY)
    const int platformId = 7;
    const char *platformString = "BB10";
#elif defined(MER_EDITION_SAILFISH)
    const int platformId = 8;
    const char *platformString = "SAILFISH";
#else
    // desktop probably
    #define PGZ_PLATFORM_DESKTOP
    const int platformId = 5;
    const char *platformString = "DESKTOP";
#endif

    void pgzRegisterPlatform(QQmlContext *context) {
        context->setContextProperty("PlatformID",  platformId);
        context->setContextProperty("PlatformString",  platformString);
    }

#endif // PGZ_PLATFORM_H
