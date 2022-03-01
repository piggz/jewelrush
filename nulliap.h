#ifndef NULLIAP_H
#define NULLIAP_H

#include <QObject>

class NullIap : public QObject
{
    Q_OBJECT
public:
    explicit NullIap(QObject *parent = 0);
    Q_INVOKABLE void purchaseItem(const QString &itemName);
    Q_INVOKABLE bool checkItemPurchased(const QString &itemName);

signals:
    void itemPurchased(const QString &itemName, int purchaseState);

};

#endif // NULLIAP_H
