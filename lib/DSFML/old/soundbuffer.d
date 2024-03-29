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
 * A sound buffer holds the data of a sound, which is an array of audio samples.
 * A sample is a 16 bits signed integer that defines the amplitude of the sound
 * at a given time. The sound is then restituted by playing these samples at a
 * high rate (for example, 44100 samples per second is the standard rate used
 * for playing CDs). In short, audio samples are like texture pixels, and a
 * SoundBuffer is similar to a Texture.
 *
 * A sound buffer can be loaded from a file (see `loadFromFile()` for the
 * complete list of supported formats), from memory, from a custom stream
 * (see $(INPUTSTREAM_LINK)) or directly from an array of samples. It can also
 * be saved back to a file.
 *
 * Sound buffers alone are not very useful: they hold the audio data but cannot
 * be played. To do so, you need to use the $(SOUND_LINK) class, which provides
 * functions to play/pause/stop the sound as well as changing the way it is
 * outputted (volume, pitch, 3D position, ...).
 *
 * This separation allows more flexibility and better performances: indeed a
 * $(U SoundBuffer) is a heavy resource, and any operation on it is slow (often
 * too slow for real-time applications). On the other side, a $(SOUND_LINK) is a
 * lightweight object, which can use the audio data of a sound buffer and change
 * the way it is played without actually modifying that data. Note that it is
 * also possible to bind several $(SOUND_LINK) instances to the same
 * $(U SoundBuffer).
 *
 * It is important to note that the Sound instance doesn't copy the buffer that
 * it uses, it only keeps a reference to it. Thus, a $(U SoundBuffer) must not
 * be destructed while it is used by a Sound (i.e. never write a function that
 * uses a local $(U SoundBuffer) instance for loading a sound).
 *
 *Example:
 * ---
 * // Declare a new sound buffer
 * auto buffer = SoundBuffer();
 *
 * // Load it from a file
 * if (!buffer.loadFromFile("sound.wav"))
 * {
 *     // error...
 * }
 *
 * // Create a sound source and bind it to the buffer
 * auto sound1 = new Sound();
 * sound1.setBuffer(buffer);
 *
 * // Play the sound
 * sound1.play();
 *
 * // Create another sound source bound to the same buffer
 * auto sound2 = new Sound();
 * sound2.setBuffer(buffer);
 *
 * // Play it with a higher pitch -- the first sound remains unchanged
 * sound2.pitch = 2;
 * sound2.play();
 * ---
 *
 * See_Also:
 * $(SOUND_LINK), $(SOUNDBUFFERRECORDER_LINK)
 */
module nudsfml.audio.old.soundbuffer;

import bindbc.sfml.audio;
import bindbc.sfml.system;

public import nudsfml.system.time;

import nudsfml.audio.inputsoundfile;
import nudsfml.audio.sound;

import nudsfml.system.inputstream;

import std.stdio;
import std.string;
import std.algorithm;
import std.array;

import nudsfml.system.err;

/**
 * Storage for audio samples defining a sound.
 */
class SoundBuffer {
    package sfSoundBuffer* sfPtr;

    /// Default constructor.
    this() {
        sfPtr = null;
    }

    /// Destructor.
    ~this() {
        import nudsfml.system.config;

        mixin(destructorOutput);
        if (sfPtr !is null) {
            sfSoundBuffer_destroy(sfPtr);
        }
    }

    /**
     * Get the array of audio samples stored in the buffer.
     *
     * The format of the returned samples is 16 bits signed integer (short).
     *
     *  Returns: Read-only array of sound samples.
     */
    const(short[]) getSamples() const {
        auto sampleCount = sfSoundBuffer_getSampleCount(sfPtr);
        if (sampleCount > 0)
            return sfSoundBuffer_getSamples(sfPtr)[0 .. sampleCount];

        return null;
    }

    /**
     * Get the sample rate of the sound.
     *
     * The sample rate is the number of samples played per second. The higher,
     * the better the quality (for example, 44100 samples/s is CD quality).
     *
     * Returns: Sample rate (number of samples per second).
     */
    uint getSampleRate() const {
        return sfSoundBuffer_getSampleRate(sfPtr);
    }

    /**
     * Get the number of channels used by the sound.
     *
     * If the sound is mono then the number of channels will be 1, 2 for stereo,
     * etc.
     *
     * Returns: Number of channels.
     */
    uint getChannelCount() const {
        return sfSoundBuffer_getChannelCount(sfPtr);
    }

    /**
     * Get the total duration of the sound.
     *
     * Returns: Sound duration.
     */
    Time getDuration() const {
        return cast(Time) sfSoundBuffer_getDuration(sfPtr);
    }

    /**
     * Load the sound buffer from a file.
     *
     * The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC. The
     * supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.
     *
     * Params:
     * 		filename =	Path of the sound file to load
     *
     * Returns: true if loading succeeded, false if it failed.
     */
    bool loadFromFile(const(char)[] filename) {
        import std.string;

        if (sfPtr !is null) {
            sfSoundBuffer_destroy(sfPtr);
        }
        sfPtr = sfSoundBuffer_createFromFile(filename.toStringz);
        return sfPtr !is null;
    }

    /**
     * Load the sound buffer from a file in memory.
     *
     * The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC. The
     * supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.
     *
     * Params:
     * 		data =	The array of data
     *
     * Returns: true if loading succeeded, false if it failed.
     */
    bool loadFromMemory(const(void)[] data) {
        if (sfPtr !is null) {
            sfSoundBuffer_destroy(sfPtr);
        }
        sfPtr = sfSoundBuffer_createFromMemory(data.ptr, data.length);
        return sfPtr !is null;
    }

    /*
     * Load the sound buffer from a custom stream.
     *
     * The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC. The
     * supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.
     *
     * Params:
     * 		stream =	Source stream to read from
     *
     * Returns: true if loading succeeded, false if it failed.
     */
    /*bool loadFromStream(InputStream stream)
    {
        return sfSoundBuffer_loadFromStream(sfPtr, new SoundBufferStream(stream));
    }
    */
    /**
     * Load the sound buffer from an array of audio samples.
     *
     * The assumed format of the audio samples is 16 bits signed integer
     * (short).
     *
     * Params:
     * 		samples      = Array of samples in memory
     * 		channelCount = Number of channels (1 = mono, 2 = stereo, ...)
     * 		sampleRate   = Sample rate (number of samples to play per second)
     *
     * Returns: true if loading succeeded, false if it failed.
     */
    bool loadFromSamples(const(short[]) samples, uint channelCount, uint sampleRate) {
        if (sfPtr !is null) {
            sfSoundBuffer_destroy(sfPtr);
        }
        sfPtr = sfSoundBuffer_createFromSamples(samples.ptr, samples.length, channelCount, sampleRate);
        return sfPtr !is null;
    }

    /**
     * Save the sound buffer to an audio file.
     *
     * The supported audio formats are: WAV, OGG/Vorbis, FLAC.
     *
     * Params:
     * 		filename =	Path of the sound file to write
     *
     * Returns: true if saving succeeded, false if it failed.
     */
    bool saveToFile(const(char)[] filename) const {
        import std.string;

        return sfSoundBuffer_saveToFile(sfPtr, filename.toStringz) > 0;
    }

}

unittest {
    version (DSFML_Unittest_Audio) {
        import std.stdio;

        writeln("Unit test for sound buffer");

        auto soundbuffer = new SoundBuffer();

        if (!soundbuffer.loadFromFile("res/TestSound.ogg")) {
            //error
            return;
        }

        writeln("Sample Rate: ", soundbuffer.getSampleRate());

        writeln("Channel Count: ", soundbuffer.getChannelCount());

        writeln("Duration: ", soundbuffer.getDuration().asSeconds());

        writeln("Sample Count: ", soundbuffer.getSamples().length);

        //use sound buffer here

        writeln();
    }
}

private extern (C++) interface sfmlInputStream {
    long read(void* data, long size);

    long seek(long position);

    long tell();

    long getSize();
}

private class SoundBufferStream : sfmlInputStream {
    private InputStream myStream;

    this(InputStream stream) {
        myStream = stream;
    }

    extern (C++) long read(void* data, long size) {
        return myStream.read(data[0 .. cast(size_t) size]);
    }

    extern (C++) long seek(long position) {
        return myStream.seek(position);
    }

    extern (C++) long tell() {
        return myStream.tell();
    }

    extern (C++) long getSize() {
        return myStream.getSize();
    }
}
