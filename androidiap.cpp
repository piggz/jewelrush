#include "androidiap.h"
#include <QDebug>

AndroidIAP::AndroidIAP(QObject *parent) :
    QObject(parent)
{
}

AndroidIAP& AndroidIAP::instance()
{
    static AndroidIAP i;
    return i;
}

void AndroidIAP::purchaseItem(const QString &itemName)
{
    qDebug() << "calling jni purchaseItem";
    QAndroidJniObject::callStaticMethod<void>("uk/co/piggz/jewelrush/JewelRushActivity","purchaseItem", "(Ljava/lang/String;)V", QAndroidJniObject::fromString(itemName).object<jstring>());
}

bool AndroidIAP::checkItemPurchased(const QString &itemName)
{
    qDebug() << "calling jni checkItemPurchased";
    return QAndroidJniObject::callStaticMethod<int>("uk/co/piggz/jewelrush/JewelRushActivity","checkItemPurchased", "(Ljava/lang/String;)I", QAndroidJniObject::fromString(itemName).object<jstring>()) != 0;
}


