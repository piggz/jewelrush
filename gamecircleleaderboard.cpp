#include "gamecircleleaderboard.h"
#include <QDebug>
#include <QtAndroidExtras/QAndroidJniObject>

GameCircleLeaderboard::GameCircleLeaderboard(QObject *parent) :
    QObject(parent)
{
}

void GameCircleLeaderboard::showLeaderBoard(const QByteArray &leaderboard) {
    m_interface.showLeaderboardOverlay(leaderboard.data());
}

void GameCircleLeaderboard::showLeaderBoards() {
    m_interface.showLeaderboardsOverlay();
}

void GameCircleLeaderboard::submitScore(const QByteArray &leaderboard, long long score) {
    m_interface.submitScore(leaderboard.data(), score, this);
}

void GameCircleLeaderboard::onSubmitScoreCb(ErrorCode errorCode, const SubmitScoreResponse *submitScoreResponse, int developerTag) {
    qDebug() << "Submit score error code:" << errorCode;
}

bool GameCircleLeaderboard::showGameCircle() {
    bool lagsReady = agsReady();
    if (lagsReady) {
        m_gameCircle.showGameCircle(this);
    }
    return lagsReady;
}

void GameCircleLeaderboard::onShowGameCircleCb(ErrorCode errorCode, int developerTag) {
    qDebug() << "Show gamecircle error code:" << errorCode;
}

bool GameCircleLeaderboard::agsReady() {
    return QAndroidJniObject::callStaticMethod<jboolean>("uk/co/piggz/jewelrush/JewelRushActivity","isAGSReady", "()Z");
}
