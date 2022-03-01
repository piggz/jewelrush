#include "nulliap.h"

NullIap::NullIap(QObject *parent) :
    QObject(parent)
{
}

bool NullIap::checkItemPurchased(const QString &itemName){
    return true;
}

void NullIap::purchaseItem(const QString &itemName)
{
    emit itemPurchased(itemName, 0);
}
