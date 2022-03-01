#ifndef HELPER_H
#define HELPER_H

#include <QObject>
#include <QSettings>
#include <QQuickItem>

#include <qplatformdefs.h>

#if defined(MEEGO_EDITION_HARMATTAN)
#include <qmsystem2/qmdisplaystate.h>
#endif

#ifdef WITH_HAPTIC
#include <QtFeedback/QFeedbackHapticsEffect>
#endif

#define	DONT_INTERSECT    0
#define	DO_INTERSECT      1
#define COLLINEAR         2

class Helper : public QObject
{
    Q_OBJECT
public:
    explicit Helper(QObject *parent = 0);
    virtual ~Helper();

signals:

public slots:
    QString keyName(int keycode);

    QVariant getSetting(const QString &settingname, QVariant def);
    bool getBoolSetting(const QString &settingname, QVariant def);

    void setSetting(const QString& settingname, QVariant val);
    bool settingExists(const QString &settingname);

    //Pause the display blanking
    void setBlankingPause();

    void rumble();

    int mmToPixels(int mm);

    int checkRectCollision(float rectX, float rectY, float rectWidth, float rectHeight, float objX, float objY, float objRadius);
    bool checkCircleCollision(float circC, float circY, float circRadius, float objX, float objY, float objRadius);
    float distanceBetweenPoints(float circC, float circY, float objX, float objY);
    bool lineCircleCollision(float lx1, float ly1, float lx2, float ly2, float cx, float cy, float radius);
    int linesIntersect( long x1, long y1,  long x2, long y2, long x3, long y3, long x4, long y4 );
    bool lineRectangleCollision(float rectX, float rectY, float rectWidth, float rectHeight, float x1, float y1,  float x2, float y2);
    void showAdvert();

private:
    QSettings settings;
#if defined(WITH_HAPTIC)
    QtMobility::QFeedbackHapticsEffect m_rumble;
#endif

#if defined(MEEGO_EDITION_HARMATTAN)
    MeeGo::QmDisplayState *displayState;
#endif

#if defined(Q_OS_PLAYBOOK)
#define mPPI 170
#elif defined(Q_OS_BLACKBERRY)
#define mPPI 320
#else
#define mPPI 96
#endif

};

#endif // HELPER_H
