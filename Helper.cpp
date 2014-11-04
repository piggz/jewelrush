#include "Helper.h"
#include <QMetaEnum>
#include <QDebug>
#include <QRectF>
#include <QPointF>
#include <QLineF>

#if defined(Q_OS_ANDROID)
#include <QScreen>
#include <QGuiApplication>
#endif

Q_DECLARE_METATYPE(QList<QObject*>)

/**************************************************************
 *                                                            *
 *    NOTE:  The following macro to determine if two numbers  *
 *    have the same sign, is for 2's complement number        *
 *    representation.  It will need to be modified for other  *
 *    number systems.                                         *
 *                                                            *
 **************************************************************/

#define SAME_SIGNS( a, b )	\
    (((long) ((unsigned long) a ^ (unsigned long) b)) >= 0 )


class StaticQtMetaObject : public QObject
{
public:
    static inline const QMetaObject& get() {return staticQtMetaObject;}
};

Helper::Helper(QObject *parent) :
    QObject(parent)
{
#if defined(MEEGO_EDITION_HARMATTAN)
#warning Building in harmattan
    displayState = 0;
#else
#warning Not building in harmattan
#endif

#if defined(WITH_HAPTIC)
#warning with haptic feedback
    m_rumble.setAttackTime(50);
    m_rumble.setIntensity(0.7);
    m_rumble.setDuration(150);
#endif
}

Helper::~Helper()
{
    qDebug() << "Syncing settings";
    settings.sync();
}

QString Helper::keyName(int keycode)
{
    int index = StaticQtMetaObject::get().indexOfEnumerator("Key");
    QMetaEnum metaEnum = StaticQtMetaObject::get().enumerator( index);
    QString keyString = metaEnum.valueToKey( keycode );
    return keyString.replace("Key_","");
    return QString();
}


QVariant Helper::getSetting(const QString &settingname, QVariant def)
{
    return settings.value("settings/" + settingname, def);
}

bool Helper::getBoolSetting(const QString &settingname, QVariant def)
{
    return getSetting(settingname, def).toBool();
}

void Helper::setSetting(const QString &settingname, QVariant val)
{
    settings.setValue("settings/" + settingname, val);
}

bool Helper::settingExists(const QString &settingname)
{
    return settings.contains("settings/" + settingname);
}

void Helper::setBlankingPause()
{
#if defined(MEEGO_EDITION_HARMATTAN)
    if (!displayState) {
        displayState = new MeeGo::QmDisplayState(this);
    }
    displayState->setBlankingPause();
#endif
}

void Helper::rumble()
{
#if defined(WITH_HAPTIC)
    m_rumble.start();
#endif
}

int Helper::mmToPixels(int mm)
{
#if defined(MEEGO_EDITION_HARMATTAN) || defined(Q_OS_SYMBIAN)
    qDebug() << "Screen 0 DPI is " << m_info.getDPIWidth(0);
    return (mm*m_info.getDPIWidth(0)) / 25.4;
#elif defined(Q_OS_ANDROID)
    qDebug() << "DPI is" << QGuiApplication::primaryScreen()->physicalDotsPerInch();
    qDebug() << "Converting " << mm << "mm to " << (mm*QGuiApplication::primaryScreen()->physicalDotsPerInch()) / 25.4 << "px";
    return (mm*QGuiApplication::primaryScreen()->physicalDotsPerInch()) / 25.4;
#else
    qDebug() << "Converting " << mm << "mm to " << (mm * mPPI) / 25.4 << "px";
    return (mm*mPPI) / 25.4;
#endif
}

int Helper::checkRectCollision(float rectX, float rectY, float rectWidth, float rectHeight, float objX, float objY, float objRadius)
{
    QRectF rect(rectX, rectY, rectWidth, rectHeight); //A rectangle representing the stationary block
    QPointF obj(objX, objY); //The center point of the bouncing item
    QPointF rectCenter = rect.center(); //the center point of the block

    QLineF collisionLine(rectCenter, obj); //The line between the 2 centers
    QPointF objBoundary = collisionLine.pointAt((collisionLine.length() - objRadius) / collisionLine.length()); //The point on the line at the radius of the bouncing item

    if (rect.contains(objBoundary)) { //Is the point inside the block
        //Work out the closest edge
        float distToTop = objBoundary.y() - rect.top();
        float distToBottom = rect.bottom() - objBoundary.y();
        float distToLeft = objBoundary.x() - rect.left();
        float distToRight = rect.right() - objBoundary.x();

        QList<float> distances;
        distances << distToTop << distToBottom << distToLeft << distToRight;
        float minDist = distances[0];

        for (int i = 0; i < 4; ++i) {
            minDist = qMin(minDist, distances[i]);
        }

        if (minDist == distToTop) return 1;
        if (minDist == distToBottom) return 2;
        if (minDist == distToLeft) return 4;
        if (minDist == distToRight) return 8;

    }

    return 0;
}

bool Helper::checkCircleCollision(float circX, float circY, float circRadius, float objX, float objY, float objRadius)
{
    QPointF obj(objX, objY); //The center point of the bouncing item
    QPointF circ(circX, circY); //the center point of the block

    QLineF collisionLine(circ, obj); //The line between the 2 centers

    if (collisionLine.length() < (circRadius + objRadius)) {
        return true;
    }
    return false;
}

float Helper::distanceBetweenPoints(float circX, float circY, float objX, float objY)
{
    QPointF obj(objX, objY); //The center point of the bouncing item
    QPointF circ(circX, circY); //the center point of the block

    QLineF collisionLine(circ, obj); //The line between the 2 centers

    return collisionLine.length();
}

bool Helper::lineCircleCollision(float lx0, float ly0, float lx1, float ly1, float x2, float y2, float r){

    bool startInside = false;
    bool endInside = false;
    bool middleInside = false;

    if ((lx0 == lx1) && (ly0 == ly1)) {
        //Line is not a line
        return false;
    }

    // Translate everything so that line segment start point to (0, 0)
    float a = lx1-lx0; // Line segment end point horizontal coordinate
    float b = ly1-ly0; // Line segment end point vertical coordinate
    float c = x2-lx0; // Circle center horizontal coordinate
    float d = y2-ly0; // Circle center vertical coordinate

    // Collision computation
    if ((d*a - c*b)*(d*a - c*b) <= r*r*(a*a + b*b)) {
        // Collision is possible
        if (c*c + d*d <= r*r) {
            // Line segment start point is inside the circle
            startInside = true;
        }
        if ((a-c)*(a-c) + (b-d)*(b-d) <= r*r) {
            // Line segment end point is inside the circle
            endInside = true;
        }
        if (!startInside && !endInside && c*a + d*b >= 0 && c*a + d*b <= a*a + b*b) {
            // Middle section only
            middleInside = true;
        }
    }
    return startInside || endInside || middleInside;
}

bool Helper::lineRectangleCollision(float rectX, float rectY, float rectWidth, float rectHeight, float x1, float y1,  float x2, float y2) {
    long x3, y3, x4, y4;
    bool collision = false;

    //Bottom
    x3 = rectX;
    y3 = rectY + rectHeight;
    x4 = rectX + rectWidth;
    y4 = rectY + rectHeight;

    collision = (linesIntersect(x1, y1, x2, y2, x3, y3, x4, y4) == DO_INTERSECT);

    //Left
    if (!collision) {
        x3 = rectX;
        y3 = rectY;
        x4 = rectX;
        y4 = rectY + rectHeight;
        collision = (linesIntersect(x1, y1, x2, y2, x3, y3, x4, y4) == DO_INTERSECT);
    }

    //Right
    if (!collision) {
        x3 = rectX + rectWidth;
        y3 = rectY;
        x4 = rectX + rectWidth;
        y4 = rectY + rectHeight;
        collision = (linesIntersect(x1, y1, x2, y2, x3, y3, x4, y4) == DO_INTERSECT);
    }

    //Top needed?
    if (!collision) {
        x3 = rectX;
        y3 = rectY;
        x4 = rectX + rectWidth;
        y4 = rectY;
        collision = (linesIntersect(x1, y1, x2, y2, x3, y3, x4, y4) == DO_INTERSECT);
    }

    return collision;
}


int Helper::linesIntersect( long x1, long y1,  long x2, long y2, long x3, long y3, long x4, long y4 )
{
    long a1, a2, b1, b2, c1, c2; /* Coefficients of line eqns. */
    long r1, r2, r3, r4;         /* 'Sign' values */
    long denom, offset, num;     /* Intermediate values */

    /* Compute a1, b1, c1, where line joining points 1 and 2
     * is "a1 x  +  b1 y  +  c1  =  0".
     */

    a1 = y2 - y1;
    b1 = x1 - x2;
    c1 = x2 * y1 - x1 * y2;

    /* Compute r3 and r4.
     */


    r3 = a1 * x3 + b1 * y3 + c1;
    r4 = a1 * x4 + b1 * y4 + c1;

    /* Check signs of r3 and r4.  If both point 3 and point 4 lie on
     * same side of line 1, the line segments do not intersect.
     */

    if ( r3 != 0 &&
         r4 != 0 &&
         SAME_SIGNS( r3, r4 ))
        return ( DONT_INTERSECT );

    /* Compute a2, b2, c2 */

    a2 = y4 - y3;
    b2 = x3 - x4;
    c2 = x4 * y3 - x3 * y4;

    /* Compute r1 and r2 */

    r1 = a2 * x1 + b2 * y1 + c2;
    r2 = a2 * x2 + b2 * y2 + c2;

    /* Check signs of r1 and r2.  If both point 1 and point 2 lie
     * on same side of second line segment, the line segments do
     * not intersect.
     */

    if ( r1 != 0 &&
         r2 != 0 &&
         SAME_SIGNS( r1, r2 ))
        return ( DONT_INTERSECT );

    /* Line segments intersect: compute intersection point.
     */

    denom = a1 * b2 - a2 * b1;
    if ( denom == 0 )
        return ( COLLINEAR );
    offset = denom < 0 ? - denom / 2 : denom / 2;

    /* The denom/2 is to get rounding instead of truncating.  It
     * is added or subtracted to the numerator, depending upon the
     * sign of the numerator.
     */

    num = b1 * c2 - b2 * c1;
    //*x = ( num < 0 ? num - offset : num + offset ) / denom;

    num = a2 * c1 - a1 * c2;
    //*y = ( num < 0 ? num - offset : num + offset ) / denom;

    return ( DO_INTERSECT );
} /* lines_intersect */
