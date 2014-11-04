import QtQuick 2.0
import QtMultimedia 5.0

//A hack around the fact the SoundEffect element doesnt work on BB10

Item {
    id: pgzSoundEffect
    property url source: ""

    Audio {
        id: buffer1
        source: pgzSoundEffect.source
    }

    Audio {
        id: buffer2
        source: pgzSoundEffect.source
    }

    Audio {
        id: buffer3
        source: pgzSoundEffect.source
    }
    Audio {
        id: buffer4
        source: pgzSoundEffect.source
    }

    function play() {
        if (!(buffer1.playbackState === Audio.PlayingState)) {
            buffer1.play();
            return;
        }
        if (!(buffer2.playbackState === Audio.PlayingState)) {
            buffer2.play();
            return;
        }
        if (!(buffer3.playbackState === Audio.PlayingState)) {
            buffer3.play();
            return;
        }
        if (!(buffer4.playbackState === Audio.PlayingState)) {
            buffer4.play();
            return;
        }
        console.log("No buffer to play sound effect", source);
        buffer1.stop();
        buffer2.stop();
        buffer3.stop();
        buffer4.stop();
    }
}
