#ifndef GAMECIRCLELEADERBOARD_H
#define GAMECIRCLELEADERBOARD_H

#include <QObject>
#include "LeaderboardsClientInterface.h"
#include "GameCircleClientInterface.h"

using namespace AmazonGames;

class GameCircleLeaderboard : public QObject, public ILeaderboardSubmitScoreCb, public IShowGameCircleCb
{
    Q_OBJECT
public:
    explicit GameCircleLeaderboard(QObject *parent = 0);

signals:

public slots:
    void showLeaderBoards();
    void showLeaderBoard(const QByteArray &leaderboard);
    void submitScore(const QByteArray &leaderboard, long long score);

    bool showGameCircle();
    bool agsReady();

private:
    AmazonGames::LeaderboardsClientInterface m_interface;
    AmazonGames::GameCircleClientInterface m_gameCircle;

    virtual void onSubmitScoreCb(
            ErrorCode errorCode,
            const SubmitScoreResponse* submitScoreResponse,
            int developerTag);

    virtual void onShowGameCircleCb(ErrorCode errorCode,
                                    int developerTag);

};

#endif // GAMECIRCLELEADERBOARD_H
