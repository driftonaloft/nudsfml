module nudsfml.audio.sound;

import bindbc.sfml.audio;
import bindbc.sfml.system;

import nudsfml.audio.soundbuffer;
import nudsfml.audio.soundstatus;
import nudsfml.system.vector3;
import nudsfml.system.time;

class Sound {
    sfSound * m_sound = null;

    this(){
        m_sound = sfSound_create();
    }

    ~this(){
        if(m_sound !is null){
            sfSound_destroy(m_sound);
        }
    }

    @property {
        SoundBuffer buffer(){
            SoundBuffer temp = new SoundBuffer(sfSound_getBuffer(m_sound));
            return temp;
        }
        void buffer(SoundBuffer soundBuffer){
            sfSound_setBuffer(m_sound, soundBuffer.m_soundBuffer);
        }
    }

    @property {
        bool loop() {
            return sfSound_getLoop(m_sound) != 0;
        }
        void loop(bool doLoop){
            sfSound_setLoop(m_sound, doLoop);
        }
    }

    @property {
        SoundStatus status() {
            sfSoundStatus stat = sfSound_getStatus(m_sound);
            return cast(SoundStatus)stat;
        }
    }

    @property {
        float pitch() {
            return sfSound_getPitch(m_sound);
        }
        void pitch(float pitch_){
            sfSound_setPitch(m_sound, pitch_);
        }
    }

    @property {
        float volume(){
            return sfSound_getVolume(m_sound);
        }

        void volume(float vol){
            if(vol < 0f){
                vol = 0f;
            } else if (vol > 100f){
                vol = 100f;
            }
            sfSound_setVolume(m_sound, vol);
        }
    }

    @property {
        void position(Vector3f pos){
            sfSound_setPosition(m_sound, cast(sfVector3f) pos);
        }
        Vector3f position(){
            return cast(Vector3f) sfSound_getPosition(m_sound);
        }
    }

    @property {
        void relativeToListener(bool relative){
            sfSound_setRelativeToListener(m_sound, relative);
        }
        bool relativeToListener(){
            return cast(bool)sfSound_isRelativeToListener(m_sound);
        }
    }

    @property {
        void minDistance(float distance){
            sfSound_setMinDistance(m_sound, distance);
        }
        float minDistance(){
            return sfSound_getMinDistance(m_sound);
        }
    }

    @property {
        void attenuation(float atten) {
            sfSound_setAttenuation(m_sound, atten);
        }
        float attenuation() {
            return sfSound_getAttenuation(m_sound);
        }
    }

    @property {
        void playingOffset(Time timeOffset){
            sfSound_setPlayingOffset(m_sound, cast(sfTime)timeOffset);
        }
        Time playingOffset(){
            return cast(Time)sfSound_getPlayingOffset(m_sound);
        }
    }

    void play(){
        sfSound_play(m_sound);
    }

    void pause() {
        sfSound_pause(m_sound);
    }

    void stop() {
        sfSound_stop(m_sound);
    }
}