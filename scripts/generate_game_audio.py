import os
import wave
import struct
import math
import numpy as np

SAMPLE_RATE = 44100

os.makedirs('assets/audio/bgm', exist_ok=True)
os.makedirs('assets/audio/sfx', exist_ok=True)

def write_wav(filename, samples, sample_rate=SAMPLE_RATE, channels=2):
    """Writes a list/numpy array of float samples (-1.0 to 1.0) to a 16-bit PCM WAV file."""
    # Ensure stereo
    if channels == 1 and len(samples.shape) == 1:
        samples = np.column_stack((samples, samples))
    elif channels == 2 and len(samples.shape) == 1:
        samples = np.column_stack((samples, samples))
    
    # Clip and convert to 16-bit int
    samples = np.clip(samples, -0.98, 0.98)
    int_samples = (samples * 32767.0).astype(np.int16)
    
    with wave.open(filename, 'wb') as wav_file:
        wav_file.setnchannels(channels)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(int_samples.tobytes())
    print(f"Generated: {filename} ({len(samples)/sample_rate:.2f}s)")

# ----------------- SYNTHESIS UTILITIES -----------------

def sine_wave(freq, duration, sample_rate=SAMPLE_RATE, phase=0.0):
    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    return np.sin(2 * np.pi * freq * t + phase)

def square_wave(freq, duration, sample_rate=SAMPLE_RATE):
    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    return np.sign(np.sin(2 * np.pi * freq * t))

def triangle_wave(freq, duration, sample_rate=SAMPLE_RATE):
    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    return 2 * np.abs(2 * (t * freq - np.floor(t * freq + 0.5))) - 1

def bell_tone(freq, duration, decay=4.0):
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    # Fundamental + harmonics
    s = (np.sin(2 * np.pi * freq * t) * np.exp(-decay * t) +
         0.4 * np.sin(2 * np.pi * freq * 2.04 * t) * np.exp(-decay * 1.5 * t) +
         0.2 * np.sin(2 * np.pi * freq * 3.01 * t) * np.exp(-decay * 2.2 * t) +
         0.1 * np.sin(2 * np.pi * freq * 4.15 * t) * np.exp(-decay * 3.0 * t))
    return s

def note_to_freq(note_str):
    # e.g., C4 = 261.63, E4 = 329.63, etc.
    notes = {'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3, 'E': 4,
             'F': 5, 'F#': 6, 'Gb': 6, 'G': 7, 'G#': 8, 'Ab': 8, 'A': 9,
             'A#': 10, 'Bb': 10, 'B': 11}
    name = note_str[:-1]
    octave = int(note_str[-1])
    semitones = notes[name] + (octave - 4) * 12
    return 440.0 * (2.0 ** ((semitones - 9) / 12.0))

# ----------------- SOUND EFFECTS (SFX) -----------------

def gen_sfx_jump():
    dur = 0.22
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    freq = np.linspace(220, 580, len(t))
    env = np.sin(np.pi * (t / dur) ** 0.6)
    tone = np.sin(2 * np.pi * freq * t) + 0.25 * np.sin(4 * np.pi * freq * t)
    return tone * env * 0.45

def gen_sfx_land():
    dur = 0.12
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    tone = np.sin(2 * np.pi * 95 * t) * np.exp(-35 * t)
    noise = (np.random.rand(len(t)) * 2 - 1) * np.exp(-45 * t) * 0.2
    return (tone + noise) * 0.5

def gen_sfx_star():
    dur = 0.8
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros(total_len)
    chords = ['C6', 'E6', 'G6', 'C7']
    step_samples = int(SAMPLE_RATE * 0.1)
    for i, n in enumerate(chords):
        f = note_to_freq(n)
        tone = bell_tone(f, 0.45, decay=6.0)
        st = i * step_samples
        end = min(st + len(tone), total_len)
        res[st:end] += tone[:end-st] * 0.35
    # Shimmer sparkle
    t = np.linspace(0, dur, total_len, endpoint=False)
    sparkle = np.sin(2 * np.pi * 3200 * t) * np.sin(2 * np.pi * 18 * t) * np.exp(-3.5 * t) * 0.08
    return res + sparkle

def gen_sfx_merit():
    dur = 1.2
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros(total_len)
    # Heart harp progression: C - E - G - B - C7
    arpeggio = ['C5', 'E5', 'G5', 'A5', 'C6', 'E6']
    step_samples = int(SAMPLE_RATE * 0.09)
    for i, n in enumerate(arpeggio):
        f = note_to_freq(n)
        tone = bell_tone(f, 0.7, decay=4.0)
        st = i * step_samples
        end = min(st + len(tone), total_len)
        res[st:end] += tone[:end-st] * 0.3
    return res

def gen_sfx_pickup():
    dur = 0.3
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    freq = np.linspace(650, 1300, len(t))
    env = np.sin(np.pi * (t / dur) ** 0.5) * np.exp(-4 * t)
    tone = (np.sin(2 * np.pi * freq * t) + 0.3 * np.sin(4 * np.pi * freq * t)) * env
    return tone * 0.45

def gen_sfx_portal():
    dur = 0.75
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    freq = 300 + 450 * (t / dur) ** 1.8
    env = np.sin(np.pi * (t / dur))
    wobble = np.sin(2 * np.pi * 16 * t) * 25
    tone = np.sin(2 * np.pi * (freq + wobble) * t) * env
    sparkles = np.sin(2 * np.pi * 2400 * t) * np.sin(2 * np.pi * 12 * t) * env * 0.2
    return (tone * 0.4 + sparkles) * 0.5

def gen_sfx_push():
    dur = 0.25
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    noise = np.random.normal(0, 1, len(t))
    # Low-pass filter approximation
    low_noise = np.convolve(noise, np.ones(15)/15, mode='same')
    scrape = np.sin(2 * np.pi * 180 * t) * low_noise
    env = np.sin(np.pi * (t / dur))
    return scrape * env * 0.4

def gen_sfx_correct():
    dur = 0.65
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    # Ding-dong chime (G5 then C6)
    t1 = np.linspace(0, 0.3, int(SAMPLE_RATE * 0.3), endpoint=False)
    t2 = np.linspace(0, 0.45, int(SAMPLE_RATE * 0.45), endpoint=False)
    ding = bell_tone(note_to_freq('G5'), 0.3, decay=6.0)
    dong = bell_tone(note_to_freq('C6'), 0.45, decay=4.5)
    res = np.zeros(len(t))
    res[:len(ding)] += ding * 0.4
    offset = int(SAMPLE_RATE * 0.16)
    res[offset:offset+len(dong)] += dong * 0.5
    return res

def gen_sfx_wrong():
    dur = 0.45
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    # Gentle low dual buzz
    t1 = np.linspace(0, 0.2, int(SAMPLE_RATE * 0.2), endpoint=False)
    t2 = np.linspace(0, 0.25, int(SAMPLE_RATE * 0.25), endpoint=False)
    b1 = square_wave(note_to_freq('Eb4'), 0.2) * np.exp(-12 * t1)
    b2 = square_wave(note_to_freq('D4'), 0.25) * np.exp(-10 * t2)
    res = np.zeros(len(t))
    res[:len(b1)] += b1 * 0.25
    offset = int(SAMPLE_RATE * 0.18)
    res[offset:offset+len(b2)] += b2 * 0.25
    return res

def gen_sfx_bus_bell():
    dur = 0.6
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    # Mechanical brass bell ding
    f1 = 1760.0 # A6
    f2 = 2793.8 # F7
    bell = (np.sin(2 * np.pi * f1 * t) * np.exp(-7 * t) +
            0.5 * np.sin(2 * np.pi * f2 * t) * np.exp(-9 * t))
    return bell * 0.5

def gen_sfx_coin():
    dur = 0.35
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    c1 = bell_tone(3520, 0.18, decay=18.0) # High metal ping
    c2 = bell_tone(4186, 0.22, decay=15.0)
    res = np.zeros(len(t))
    res[:len(c1)] += c1 * 0.35
    offset = int(SAMPLE_RATE * 0.08)
    res[offset:offset+len(c2)] += c2 * 0.35
    return res

def gen_sfx_recycle():
    dur = 0.3
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    click = np.sin(2 * np.pi * 880 * t) * np.exp(-40 * t) * 0.3
    thump = np.sin(2 * np.pi * 120 * t) * np.exp(-25 * t) * 0.4
    return click + thump

def gen_sfx_bloom():
    dur = 1.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros(total_len)
    notes = ['C5', 'E5', 'G5', 'B5', 'C6', 'E6', 'G6']
    step = int(SAMPLE_RATE * 0.08)
    for i, n in enumerate(notes):
        f = note_to_freq(n)
        tone = bell_tone(f, 0.6, decay=5.0)
        st = i * step
        end = min(st + len(tone), total_len)
        res[st:end] += tone[:end-st] * 0.25
    return res

def gen_sfx_umbrella():
    dur = 0.35
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    # Snap click + fabric whoosh
    snap = np.sin(2 * np.pi * 1400 * t) * np.exp(-60 * t) * 0.4
    whoosh = (np.random.rand(len(t)) * 2 - 1) * np.sin(np.pi * (t / dur) ** 0.5) * np.exp(-8 * t) * 0.35
    return snap + whoosh

def gen_sfx_switch():
    dur = 0.15
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    click1 = np.sin(2 * np.pi * 1800 * t) * np.exp(-80 * t) * 0.4
    click2 = np.sin(2 * np.pi * 850 * t) * np.exp(-50 * t) * 0.3
    return click1 + click2

def gen_sfx_dialog_blip():
    dur = 0.045
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    tone = np.sin(2 * np.pi * 680 * t) * np.sin(np.pi * t / dur)
    return tone * 0.25

def gen_sfx_victory():
    dur = 2.2
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros(total_len)
    chords = [
        (['C5', 'E5', 'G5'], 0.0, 0.35),
        (['E5', 'G5', 'B5'], 0.35, 0.35),
        (['F5', 'A5', 'C6'], 0.70, 0.4),
        (['G5', 'B5', 'D6'], 1.10, 0.4),
        (['C5', 'G5', 'C6', 'E6'], 1.50, 0.7)
    ]
    for chord, st_time, ch_dur in chords:
        st = int(st_time * SAMPLE_RATE)
        for n in chord:
            f = note_to_freq(n)
            tone = bell_tone(f, ch_dur, decay=2.5)
            end = min(st + len(tone), total_len)
            res[st:end] += tone[:end-st] * 0.2
    return res

# ----------------- BACKGROUND MUSIC & AMBIENCE LOOPS (8 to 12s seamless) -----------------

def gen_bgm_home_morning():
    """Scene 1: Morning acoustic chime & bird chirp loop (8s)"""
    dur = 8.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    t = np.linspace(0, dur, total_len, endpoint=False)
    
    # Warm gentle acoustic progression: C - G - Am - F
    progression = [
        (['C4', 'E4', 'G4', 'C5'], 0.0),
        (['G3', 'D4', 'G4', 'B4'], 2.0),
        (['A3', 'C4', 'E4', 'A4'], 4.0),
        (['F3', 'A3', 'C4', 'F4'], 6.0)
    ]
    for chord, st_t in progression:
        st = int(st_t * SAMPLE_RATE)
        for idx, n in enumerate(chord):
            f = note_to_freq(n)
            # Arpeggiated fingerpicking
            note_st = st + int(idx * 0.25 * SAMPLE_RATE)
            tone = bell_tone(f, 1.8, decay=2.2)
            end = min(note_st + len(tone), total_len)
            pan = 0.3 if idx % 2 == 0 else 0.7
            res[note_st:end, 0] += tone[:end-note_st] * (1 - pan) * 0.22
            res[note_st:end, 1] += tone[:end-note_st] * pan * 0.22
            
    # Soft bird chirps in distance
    chirp_times = [1.2, 3.5, 5.8]
    for ct in chirp_times:
        st = int(ct * SAMPLE_RATE)
        cdur = 0.15
        t_c = np.linspace(0, cdur, int(SAMPLE_RATE * cdur), endpoint=False)
        cfreq = 2800 + 900 * np.sin(2 * np.pi * 14 * t_c)
        chirp = np.sin(2 * np.pi * cfreq * t_c) * np.sin(np.pi * t_c / cdur) * 0.06
        end = min(st + len(chirp), total_len)
        res[st:end, 0] += chirp[:end-st] * 0.4
        res[st:end, 1] += chirp[:end-st] * 0.8
        
    return res

def gen_bgm_village_lively():
    """Scene 2: Lively village street melody with bicycle bell (8s)"""
    dur = 8.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    
    # Cheerful marimba / acoustic rhythm in G major
    melody = [
        ('G4', 0.0), ('B4', 0.5), ('D5', 1.0), ('G5', 1.5),
        ('E5', 2.0), ('D5', 2.5), ('B4', 3.0), ('A4', 3.5),
        ('B4', 4.0), ('D5', 4.5), ('G5', 5.0), ('A5', 5.5),
        ('G5', 6.0), ('D5', 6.5), ('B4', 7.0), ('G4', 7.5)
    ]
    for n, st_t in melody:
        st = int(st_t * SAMPLE_RATE)
        f = note_to_freq(n)
        tone = bell_tone(f, 0.4, decay=4.5)
        end = min(st + len(tone), total_len)
        res[st:end, 0] += tone[:end-st] * 0.2
        res[st:end, 1] += tone[:end-st] * 0.2
        
    # Light bicycle bell at 3.2s
    b_st = int(3.2 * SAMPLE_RATE)
    bbell = bell_tone(2489, 0.35, decay=12.0) * 0.15
    end = min(b_st + len(bbell), total_len)
    res[b_st:end, 0] += bbell[:end-b_st]
    res[b_st:end, 1] += bbell[:end-b_st]
    return res

def gen_bgm_bus_stop():
    """Scene 2.5: Roadside morning breeze & bird song (8s)"""
    dur = 8.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    t = np.linspace(0, dur, total_len, endpoint=False)
    
    # Gentle wind noise
    noise = np.random.normal(0, 1, total_len)
    breeze = np.convolve(noise, np.ones(80)/80, mode='same') * 0.08
    res[:, 0] += breeze
    res[:, 1] += breeze
    
    # Soft acoustic chime
    chimes = [('D4', 0.5), ('F#4', 2.0), ('A4', 3.5), ('D5', 5.0), ('A4', 6.5)]
    for n, st_t in chimes:
        st = int(st_t * SAMPLE_RATE)
        f = note_to_freq(n)
        tone = bell_tone(f, 1.4, decay=2.5) * 0.16
        end = min(st + len(tone), total_len)
        res[st:end, 0] += tone[:end-st] * 0.5
        res[st:end, 1] += tone[:end-st] * 0.7
    return res

def gen_bgm_bus_ride():
    """Scene 3: Bus engine hum, rhythmic road vibration (8s)"""
    dur = 8.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    t = np.linspace(0, dur, total_len, endpoint=False)
    
    # Engine diesel hum (harmonic fundamental 75Hz + 150Hz + 225Hz)
    engine = (0.22 * np.sin(2 * np.pi * 75 * t) +
              0.14 * np.sin(2 * np.pi * 150 * t) +
              0.08 * np.sin(2 * np.pi * 225 * t))
    # Rhythmic road seams every 1.5 seconds
    seam = np.zeros(total_len)
    for st_t in [0.5, 2.0, 3.5, 5.0, 6.5]:
        st = int(st_t * SAMPLE_RATE)
        sdur = 0.08
        t_s = np.linspace(0, sdur, int(SAMPLE_RATE * sdur), endpoint=False)
        bump = np.sin(2 * np.pi * 60 * t_s) * np.exp(-30 * t_s) * 0.15
        end = min(st + len(bump), total_len)
        seam[st:end] += bump[:end-st]
        
    res[:, 0] = engine * 0.7 + seam
    res[:, 1] = engine * 0.7 + seam * 0.8
    return res

def gen_bgm_terminal_bustle():
    """Scene 4: Bustling bus terminal ambience (8s)"""
    dur = 8.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    t = np.linspace(0, dur, total_len, endpoint=False)
    
    # Upbeat travel groove: bassline + light horn
    bass = [('F3', 0.0), ('F3', 0.5), ('A3', 1.0), ('C4', 1.5),
            ('Bb3', 2.0), ('D4', 2.5), ('C4', 3.0), ('F3', 3.5),
            ('F3', 4.0), ('F3', 4.5), ('A3', 5.0), ('C4', 5.5),
            ('Bb3', 6.0), ('C4', 6.5), ('F3', 7.0), ('F3', 7.5)]
    for n, st_t in bass:
        st = int(st_t * SAMPLE_RATE)
        f = note_to_freq(n)
        tone = triangle_wave(f, 0.3) * np.exp(-4 * np.linspace(0, 0.3, int(SAMPLE_RATE * 0.3))) * 0.18
        end = min(st + len(tone), total_len)
        res[st:end, 0] += tone[:end-st]
        res[st:end, 1] += tone[:end-st]
        
    # Distant friendly bus horn beep at 2.4s and 6.2s
    for ht in [2.4, 6.2]:
        st = int(ht * SAMPLE_RATE)
        hdur = 0.2
        t_h = np.linspace(0, hdur, int(SAMPLE_RATE * hdur), endpoint=False)
        horn = (np.sin(2 * np.pi * 370 * t_h) + np.sin(2 * np.pi * 440 * t_h)) * np.sin(np.pi * t_h / hdur) * 0.08
        end = min(st + len(horn), total_len)
        res[st:end, 0] += horn[:end-st] * 0.6
        res[st:end, 1] += horn[:end-st] * 0.4
    return res

def gen_bgm_school_morning():
    """Scene 5: School gate & entrance excitement (8s)"""
    dur = 8.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    
    # Bright cheerful brass/piano theme in C major
    theme = [
        ('C4', 0.0), ('E4', 0.5), ('G4', 1.0), ('C5', 1.5),
        ('B4', 2.0), ('C5', 2.5), ('A4', 3.0), ('G4', 3.5),
        ('F4', 4.0), ('A4', 4.5), ('C5', 5.0), ('D5', 5.5),
        ('C5', 6.0), ('G4', 6.5), ('E4', 7.0), ('C4', 7.5)
    ]
    for n, st_t in theme:
        st = int(st_t * SAMPLE_RATE)
        f = note_to_freq(n)
        tone = bell_tone(f, 0.45, decay=3.5) * 0.22
        end = min(st + len(tone), total_len)
        res[st:end, 0] += tone[:end-st]
        res[st:end, 1] += tone[:end-st]
    return res

def gen_bgm_classroom():
    """Scene 6: Academic marimba & xylophone curiosity (8s)"""
    dur = 8.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    
    # Playful xylophone staccato
    notes = [
        ('E4', 0.0), ('G4', 0.25), ('A4', 0.5), ('B4', 0.75),
        ('C5', 1.0), ('B4', 1.25), ('A4', 1.5), ('G4', 1.75),
        ('E4', 2.0), ('G4', 2.5), ('A4', 3.0), ('D4', 3.5),
        ('E4', 4.0), ('G4', 4.25), ('A4', 4.5), ('B4', 4.75),
        ('D5', 5.0), ('C5', 5.25), ('B4', 5.5), ('A4', 5.75),
        ('G4', 6.0), ('A4', 6.5), ('G4', 7.0), ('E4', 7.5)
    ]
    for n, st_t in notes:
        st = int(st_t * SAMPLE_RATE)
        f = note_to_freq(n)
        tone = sine_wave(f, 0.2) * np.exp(-14 * np.linspace(0, 0.2, int(SAMPLE_RATE * 0.2))) * 0.22
        end = min(st + len(tone), total_len)
        res[st:end, 0] += tone[:end-st]
        res[st:end, 1] += tone[:end-st]
    return res

def gen_bgm_canteen():
    """Scene 7: Lively cafeteria energy & lunch rhythm (8s)"""
    dur = 8.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    
    # Bouncy upbeat acoustic groove
    melody = [
        ('C4', 0.0), ('G4', 0.4), ('A4', 0.8), ('G4', 1.2),
        ('F4', 1.6), ('E4', 2.0), ('D4', 2.4), ('G4', 2.8),
        ('C4', 3.2), ('G4', 3.6), ('A4', 4.0), ('B4', 4.4),
        ('C5', 4.8), ('G4', 5.4), ('E4', 6.0), ('C4', 6.6)
    ]
    for n, st_t in melody:
        st = int(st_t * SAMPLE_RATE)
        f = note_to_freq(n)
        tone = triangle_wave(f, 0.35) * np.exp(-5 * np.linspace(0, 0.35, int(SAMPLE_RATE * 0.35))) * 0.2
        end = min(st + len(tone), total_len)
        res[st:end, 0] += tone[:end-st]
        res[st:end, 1] += tone[:end-st]
    return res

def gen_bgm_school_garden():
    """Scene 8: Nature breeze, pond water ripples, wind chimes (8s)"""
    dur = 8.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    t = np.linspace(0, dur, total_len, endpoint=False)
    
    # Peaceful wind chimes in pentatonic scale
    chimes = ['D5', 'F#5', 'A5', 'B5', 'D6', 'F#6']
    times = [0.4, 1.8, 3.2, 4.6, 6.0, 7.2]
    for idx, (n, st_t) in enumerate(zip(chimes, times)):
        st = int(st_t * SAMPLE_RATE)
        f = note_to_freq(n)
        tone = bell_tone(f, 1.2, decay=3.0) * 0.18
        end = min(st + len(tone), total_len)
        pan = 0.3 if idx % 2 == 0 else 0.7
        res[st:end, 0] += tone[:end-st] * (1 - pan)
        res[st:end, 1] += tone[:end-st] * pan
        
    # Gentle water ripple texture
    noise = np.random.normal(0, 1, total_len)
    ripple = np.convolve(noise, np.ones(100)/100, mode='same') * 0.05
    res[:, 0] += ripple
    res[:, 1] += ripple
    return res

def gen_bgm_songthaew_ride():
    """Scene 9: Return Songthaew wooden bed rumble (8s)"""
    dur = 8.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    t = np.linspace(0, dur, total_len, endpoint=False)
    
    # 4-cylinder engine chug + open air wind
    engine = (0.2 * np.sin(2 * np.pi * 65 * t) +
              0.12 * np.sin(2 * np.pi * 130 * t) +
              0.08 * np.sin(2 * np.pi * 195 * t))
    # Wind whoosh
    noise = np.random.normal(0, 1, total_len)
    wind = np.convolve(noise, np.ones(60)/60, mode='same') * 0.08
    res[:, 0] = engine + wind * 0.9
    res[:, 1] = engine + wind * 1.1
    return res

def gen_bgm_bus_sunset():
    """Scene 10: Golden hour bus ride, chill sunset relaxation (8s)"""
    dur = 8.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    
    # Soft electric piano jazz/chill chords: Fmaj7 - Em7 - Dm7 - Cmaj7
    chords = [
        (['F3', 'A3', 'C4', 'E4'], 0.0),
        (['E3', 'G3', 'B3', 'D4'], 2.0),
        (['D3', 'F3', 'A3', 'C4'], 4.0),
        (['C3', 'E3', 'G3', 'B3'], 6.0)
    ]
    for chord, st_t in chords:
        st = int(st_t * SAMPLE_RATE)
        for n in chord:
            f = note_to_freq(n)
            tone = sine_wave(f, 2.0) * np.exp(-1.2 * np.linspace(0, 2.0, int(SAMPLE_RATE * 2.0))) * 0.16
            end = min(st + len(tone), total_len)
            res[st:end, 0] += tone[:end-st]
            res[st:end, 1] += tone[:end-st]
    return res

def gen_bgm_rainy_village():
    """Scene 11: Soothing rain shower, distant thunder, gentle piano (8s)"""
    dur = 8.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    t = np.linspace(0, dur, total_len, endpoint=False)
    
    # Continuous realistic rain noise (bandpass filtered white noise)
    noise = np.random.normal(0, 1, total_len)
    rain = np.convolve(noise, np.ones(25)/25, mode='same') * 0.14
    res[:, 0] += rain
    res[:, 1] += rain * 1.05
    
    # Gentle sentimental piano in D minor
    notes = [('D4', 0.5), ('F4', 1.5), ('A4', 2.5), ('G4', 4.0), ('F4', 5.0), ('E4', 6.0), ('D4', 7.0)]
    for n, st_t in notes:
        st = int(st_t * SAMPLE_RATE)
        f = note_to_freq(n)
        tone = bell_tone(f, 1.2, decay=2.8) * 0.18
        end = min(st + len(tone), total_len)
        res[st:end, 0] += tone[:end-st] * 0.6
        res[st:end, 1] += tone[:end-st] * 0.6
    return res

def gen_bgm_home_night():
    """Scene 12: Night crickets & cozy music box lullaby (8s)"""
    dur = 8.0
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    t = np.linspace(0, dur, total_len, endpoint=False)
    
    # Crickets chirping softly in background
    crickets = np.zeros(total_len)
    for c_t in [0.2, 0.4, 0.6, 2.0, 2.2, 2.4, 4.0, 4.2, 4.4, 6.0, 6.2, 6.4]:
        st = int(c_t * SAMPLE_RATE)
        cdur = 0.08
        t_c = np.linspace(0, cdur, int(SAMPLE_RATE * cdur), endpoint=False)
        chirp = np.sin(2 * np.pi * 4500 * t_c) * np.sin(np.pi * t_c / cdur) * 0.04
        end = min(st + len(chirp), total_len)
        crickets[st:end] += chirp[:end-st]
        
    res[:, 0] += crickets * 0.6
    res[:, 1] += crickets * 0.9
    
    # Celesta / Music Box bedtime lullaby
    lullaby = [
        ('C5', 0.0), ('G5', 0.6), ('E5', 1.2), ('C5', 1.8),
        ('D5', 2.4), ('F5', 3.0), ('E5', 3.6), ('D5', 4.2),
        ('E5', 4.8), ('G5', 5.4), ('C6', 6.0), ('G5', 6.6),
        ('E5', 7.2)
    ]
    for n, st_t in lullaby:
        st = int(st_t * SAMPLE_RATE)
        f = note_to_freq(n)
        tone = bell_tone(f, 1.0, decay=3.2) * 0.22
        end = min(st + len(tone), total_len)
        res[st:end, 0] += tone[:end-st] * 0.5
        res[st:end, 1] += tone[:end-st] * 0.5
    return res

# ----------------- MAIN EXECUTION -----------------
print("Synthesizing SFX...")
sfx_list = [
    ('sfx_jump.wav', gen_sfx_jump),
    ('sfx_land.wav', gen_sfx_land),
    ('sfx_star.wav', gen_sfx_star),
    ('sfx_merit.wav', gen_sfx_merit),
    ('sfx_pickup.wav', gen_sfx_pickup),
    ('sfx_portal.wav', gen_sfx_portal),
    ('sfx_push.wav', gen_sfx_push),
    ('sfx_correct.wav', gen_sfx_correct),
    ('sfx_wrong.wav', gen_sfx_wrong),
    ('sfx_bus_bell.wav', gen_sfx_bus_bell),
    ('sfx_coin.wav', gen_sfx_coin),
    ('sfx_recycle.wav', gen_sfx_recycle),
    ('sfx_bloom.wav', gen_sfx_bloom),
    ('sfx_umbrella.wav', gen_sfx_umbrella),
    ('sfx_switch.wav', gen_sfx_switch),
    ('sfx_dialog_blip.wav', gen_sfx_dialog_blip),
    ('sfx_victory.wav', gen_sfx_victory)
]
for fname, func in sfx_list:
    samples = func()
    write_wav(os.path.join('assets/audio/sfx', fname), samples, channels=1)

print("\nSynthesizing BGM & Ambience loops...")
bgm_list = [
    ('bgm_home_morning.wav', gen_bgm_home_morning),
    ('bgm_village_lively.wav', gen_bgm_village_lively),
    ('bgm_bus_stop.wav', gen_bgm_bus_stop),
    ('bgm_bus_ride.wav', gen_bgm_bus_ride),
    ('bgm_terminal_bustle.wav', gen_bgm_terminal_bustle),
    ('bgm_school_morning.wav', gen_bgm_school_morning),
    ('bgm_classroom.wav', gen_bgm_classroom),
    ('bgm_canteen.wav', gen_bgm_canteen),
    ('bgm_school_garden.wav', gen_bgm_school_garden),
    ('bgm_songthaew_ride.wav', gen_bgm_songthaew_ride),
    ('bgm_bus_sunset.wav', gen_bgm_bus_sunset),
    ('bgm_rainy_village.wav', gen_bgm_rainy_village),
    ('bgm_home_night.wav', gen_bgm_home_night)
]
for fname, func in bgm_list:
    samples = func()
    write_wav(os.path.join('assets/audio/bgm', fname), samples, channels=2)

print("\nAll 30 audio assets generated successfully!")
