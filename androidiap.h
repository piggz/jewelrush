#ifndef ANDROIDIAP_H
#define ANDROIDIAP_H

#include <QObject>
#include <QtAndroidExtras/QAndroidJniObject>
#include <QDebug>

class AndroidIAP : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE void purchaseItem(const QString &itemName);
    Q_INVOKABLE bool checkItemPurchased(const QString &itemName);

    static AndroidIAP &instance();

signals:
    void itemPurchased(const QString &itemName, int purchaseState);

private:
    AndroidIAP(QObject *parent = 0);
    AndroidIAP(AndroidIAP const&);              // Don't Implement
    void operator=(AndroidIAP const&); // Don't implement
};

static void itemPurchased(JNIEnv *env, jclass /*clazz*/, jstring itemName, int purchaseState)
{
    const char *nativeString = (env)->GetStringUTFChars(itemName, 0);
    qDebug() << "in itemPurchased" << nativeString;

    AndroidIAP::instance().itemPurchased(nativeString, purchaseState);
    (env)->ReleaseStringUTFChars(itemName, nativeString);
}

#endif // ANDROIDIAP_H
