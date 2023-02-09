module nudsfml.audio.soundbuffer;

import std.string;
import bindbc.sfml.audio;

import nudsfml.system.time;
import nudsfml.system.vector3;

import nudsfml.audio.soundstatus;

class SoundBuffer {
    sfSoundBuffer* m_soundBuffer = null;

    this(const(sfSoundBuffer)* other){
        m_soundBuffer = sfSoundBuffer_copy(other);
    }

    this(SoundBuffer other) {
        m_soundBuffer = sfSoundBuffer_copy(other.m_soundBuffer);
    }
    this(string filename){
        createFromFile(filename);
    }
    this(void[] data){
        createFromMemory(data);
    }
    ~this(){
        if(m_soundBuffer !is null){
            sfSoundBuffer_destroy(m_soundBuffer);
        }
    }
    @property {
        short[] samples() {
            import core.stdc.string;
            short* temp = cast(short*) sfSoundBuffer_getSamples(m_soundBuffer);
            size_t length = sfSoundBuffer_getSampleCount(m_soundBuffer);

            short[] retval;
            retval.length = length;
            memcpy(temp, retval.ptr, length);

            return retval;
        }
    }
    @property {
        uint sampleRate(){
            return sfSoundBuffer_getSampleRate(m_soundBuffer);
        }
    }
    @property {
        uint channelCount(){
            return sfSoundBuffer_getChannelCount(m_soundBuffer);
        }
    }
    @property {
        Time duration(){
            return cast(Time) sfSoundBuffer_getDuration(m_soundBuffer);
        }
    }

    bool createFromFile(string filename){
        if(m_soundBuffer !is null){
            sfSoundBuffer_destroy(m_soundBuffer);
        }
        m_soundBuffer = sfSoundBuffer_createFromFile(filename.toStringz);
        return m_soundBuffer !is null;
    }
    bool createFromMemory(void[] data){
        if(m_soundBuffer !is null){
            sfSoundBuffer_destroy(m_soundBuffer);
        }
        m_soundBuffer = sfSoundBuffer_createFromMemory(data.ptr, data.length);
        return m_soundBuffer !is null;
    }
}