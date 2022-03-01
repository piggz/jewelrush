#ifndef SCOREMODEL_H
#define SCOREMODEL_H

#include <QAbstractListModel>

class Score {
public:
    int score;
    QString levelId;
    QString levelName;
    int stage;
    int level;
    QString date;

    bool operator<(const Score& b) const { return score > b.score; }
};

class ScoreModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum ScorePackRoles {
        ScorePositionRole = Qt::UserRole + 1,
        ScoreRole,
        ScoreLevelIdRole,
        ScoreLevelNameRole,
        ScoreStageRole,
        ScoreCurrentLevelRole,
        ScoreDateRole
    };
    explicit ScoreModel(QObject *parent = 0);
    virtual int rowCount(const QModelIndex &parent) const;
    virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole ) const;
    virtual QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE bool addScore(int score, const QString& levelId, const QString& levelName, int stage, int currentlevel, const QString& date);
    Q_INVOKABLE bool saveScores();
    Q_INVOKABLE bool loadScores();
    Q_INVOKABLE int bestScore();
    Q_INVOKABLE int bestLevel();

private:
    QList<Score> m_scores;

};

#endif // SCOREMODEL_H
