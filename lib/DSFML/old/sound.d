/*
 * DSFML - The Simple and Fast Multimedia Library for D
 *
 * Copyright (c) 2013 - 2018 Jeremy DeHaan (dehaan.jeremiah@gmail.com)
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from the
 * use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not claim
 * that you wrote the original software. If you use this software in a product,
 * an acknowledgment in the product documentation would be appreciated but is
 * not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source distribution
 *
 *
 * DSFML is based on SFML (Copyright Laurent Gomila)
 */

/**
 * Sound is the class used to play sounds.
 *
 * It provides:
 * $(UL
 * $(LI Control (play, pause, stop))
 * $(LI Ability to modify output parameters in real-time (pitch, volume, ...))
 * $(LI 3D spatial features (position, attenuation, ...)))
 *
 * $(PARA
 * Sound is perfect for playing short sounds that can fit in memory and require
 * no latency, like foot steps or gun shots. For longer sounds, like background
 * musics or long speeches, rather see Music (which is based on streaming).
 *
 * In order to work, a sound must be given a buffer of audio data to play. Audio
 * data (samples) is stored in SoundBuffer, and attached to a sound with the
 * setBuffer() function. The buffer object attached to a sound must remain alive
 * as long as the sound uses it. Note that multiple sounds can use the same
 * sound buffer at the same time.
 *)
 *
 * Example:
 * ---
 * auto buffer = new SoundBuffer();
 * buffer.loadFromFile("sound.wav");
 *
 * auto sound = new Sound();
 * sound.setBuffer(buffer);
 * sound.play();
 * ---
 *
 * See_Also:
 * $(SOUNDBUFFER_LINK), $(MUSIC_LINK)
 */
module nudsfml.audio.old.sound;

import bindbc.sfml.audio;
import bindbc.sfml.system;

public import nudsfml.system.time;

import nudsfml.audio.soundbuffer;
import nudsfml.audio.soundsource;

import nudsfml.system.vector3;

enum Status {
    Stopped,
    Paused,
    Playing
}

/**
 * Regular sound that can be played in the audio environment.
 */
class Sound {
    import std.typecons : Rebindable;

    //Const AND able to be rebound. Word.
    private Rebindable!(const(SoundBuffer)) m_buffer;
    package sfSound* sfPtr = null;

    /// Default constructor.
    this() {
        sfPtr = sfSound_create();
    }

    /**
     * Construct the sound with a buffer.
     *
     * Params:
     *	buffer = Sound buffer containing the audio data to play with the sound
     */
    this(const(SoundBuffer) buffer) {
        this();

        setBuffer(buffer);
    }

    /// Destructor.
    ~this() {
        import nudsfml.system.config;

        mixin(destructorOutput);
        //stop the sound
        stop();

        sfSound_destroy(sfPtr);
    }

    @property {
        /**
         * Whether or not the sound should loop after reaching the end.
         *
         * If set, the sound will restart from beginning after reaching the end and
         * so on, until it is stopped or setLoop(false) is called.
         *
         * The default looping state for sound is false.
         */
        void isLooping(bool loop) {
            sfSound_setLoop(sfPtr, loop);
        }

        /// ditto
        bool isLooping() const {
            return sfSound_getLoop(sfPtr) > 0;
        }
    }

    @property {
        /**
         * Change the current playing position (from the beginning) of the sound.
         *
         * The playing position can be changed when the sound is either paused or
         * playing.
         */
        void playingOffset(Time offset) {
            sfSound_setPlayingOffset(sfPtr, cast(sfTime) offset);
        }

        /// ditto
        Time playingOffset() const {
            return cast(Time) sfSound_getPlayingOffset(sfPtr);
        }
    }

    @property {
        /**
         * Get the current status of the sound (stopped, paused, playing).
         */
        Status status() const {
            return cast(Status) sfSound_getStatus(sfPtr);
        }
    }

    //from SoundSource
    @property {
        /**
         * The pitch of the sound.
         *
         * The pitch represents the perceived fundamental frequency of a sound; thus
         * you can make a sound more acute or grave by changing its pitch. A side
         * effect of changing the pitch is to modify the playing speed of the sound
         * as well. The default value for the pitch is 1.
         */
        void pitch(float newPitch) {
            sfSound_setPitch(sfPtr, newPitch);
        }

        /// ditto
        float pitch() const {
            return sfSound_getPitch(sfPtr);
        }
    }

    @property {
        /**
         * The volume of the sound.
         *
         * The volume is a value between 0 (mute) and 100 (full volume). The
         * default value for the volume is 100.
         */
        void volume(float newVolume) {
            sfSound_setVolume(sfPtr, newVolume);
        }

        /// ditto
        float volume() const {
            return sfSound_getVolume(sfPtr);
        }
    }

    @property {
        /**
         * The 3D position of the sound in the audio scene.
         *
         * Only sounds with one channel (mono sounds) can be spatialized. The
         * default position of a sound is (0, 0, 0).
         */
        void position(Vector3f newPosition) {
            sfSound_setPosition(sfPtr, cast(sfVector3f) newPosition);
        }

        /// ditto
        Vector3f position() const {
            Vector3f temp = cast(Vector3f) sfSound_getPosition(sfPtr);
            return temp;
        }
    }

    @property {
        /**
         * Make the sound's position relative to the listener (true) or absolute
         * (false).
         *
         * Making a sound relative to the listener will ensure that it will always
         * be played the same way regardless the position of the listener.  This can
         * be useful for non-spatialized sounds, sounds that are produced by the
         * listener, or sounds attached to it. The default value is false
         * (position is absolute).
         */
        void relativeToListener(bool relative) {
            sfSound_setRelativeToListener(sfPtr, relative);
        }

        /// ditto
        bool relativeToListener() const {
            return sfSound_isRelativeToListener(sfPtr) > 0;
        }
    }

    @property {
        /**
         * The minimum distance of the sound.
         *
         * The "minimum distance" of a sound is the maximum distance at which it is
         * heard at its maximum volume. Further than the minimum distance, it will
         * start to fade out according to its attenuation factor. A value of 0
         * ("inside the head of the listener") is an invalid value and is forbidden.
         * The default value of the minimum distance is 1.
         */
        void minDistance(float distance) {
            sfSound_setMinDistance(sfPtr, distance);
        }

        /// ditto
        float minDistance() const {
            return sfSound_getMinDistance(sfPtr);
        }
    }

    @property {
        /**
         * The attenuation factor of the sound.
         *
         * The attenuation is a multiplicative factor which makes the sound more or
         * less loud according to its distance from the listener. An attenuation of
         * 0 will produce a non-attenuated sound, i.e. its volume will always be the
         * same whether it is heard from near or from far.
         *
         * On the other hand, an attenuation value such as 100 will make the sound
         * fade out very quickly as it gets further from the listener. The default
         * value of the attenuation is 1.
         */
        void attenuation(float newAttenuation) {
            sfSound_setAttenuation(sfPtr, newAttenuation);
        }

        /// ditto
        float attenuation() const {
            return sfSound_getAttenuation(sfPtr);
        }
    }

    /*
     * Set the source buffer containing the audio data to play.
     *
     * It is important to note that the sound buffer is not copied, thus the
     * SoundBuffer instance must remain alive as long as it is attached to the
     * sound.
     *
     * Params:
     * 		buffer =	Sound buffer to attach to the sound
     */
    void setBuffer(const(SoundBuffer) buffer) {
        m_buffer = buffer;
        sfSound_setBuffer(sfPtr, buffer.sfPtr);
    }

    /**
     * Pause the sound.
     *
     * This function pauses the sound if it was playing, otherwise
     * (sound already paused or stopped) it has no effect.
     */
    void pause() {
        sfSound_pause(sfPtr);
    }

    /**
     * Start or resume playing the sound.
     *
     * This function starts the stream if it was stopped, resumes it if it was
     * paused, and restarts it from beginning if it was it already playing.
     *
     * This function uses its own thread so that it doesn't block the rest of
     * the program while the sound is played.
     */
    void play() {
        sfSound_play(sfPtr);
    }

    /**
     * Stop playing the sound.
     *
     * This function stops the sound if it was playing or paused, and does
     * nothing if it was already stopped. It also resets the playing position
     * (unlike `pause()`).
     */
    void stop() {
        sfSound_stop(sfPtr);
    }
}

unittest {
    version (DSFML_Unittest_Audio) {
        import std.stdio;
        import nudsfml.system.clock;

        writeln("Unit test for Sound class");

        //first, get a sound buffer

        auto soundbuffer = new SoundBuffer();

        if (!soundbuffer.loadFromFile("data/TestSound.ogg")) {
            //error
            return;
        }

        float duration = soundbuffer.getDuration().asSeconds();

        auto sound = new Sound(soundbuffer);

        //sound.relativeToListener(true);

        auto clock = new Clock();
        //play the sound!
        sound.play();

        while (clock.getElapsedTime().asSeconds() < duration) {
            //wait for sound to finish
        }

        //clock.restart();

        //sound.relativeToListener(false);

        writeln();
    }
}
