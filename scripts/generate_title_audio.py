import os
import wave
import struct
import math
import numpy as np

SAMPLE_RATE = 44100

os.makedirs('assets/audio/bgm', exist_ok=True)
os.makedirs('assets/audio/sfx', exist_ok=True)

def write_wav(filename, samples, sample_rate=SAMPLE_RATE, channels=2):
    if channels == 1 and len(samples.shape) == 1:
        samples = np.column_stack((samples, samples))
    elif channels == 2 and len(samples.shape) == 1:
        samples = np.column_stack((samples, samples))
    
    samples = np.clip(samples, -0.98, 0.98)
    int_samples = (samples * 32767.0).astype(np.int16)
    
    with wave.open(filename, 'wb') as wav_file:
        wav_file.setnchannels(channels)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(int_samples.tobytes())
    print(f"Generated: {filename} ({len(samples)/sample_rate:.2f}s)")

def note_to_freq(note_str):
    notes = {'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3, 'E': 4,
             'F': 5, 'F#': 6, 'Gb': 6, 'G': 7, 'G#': 8, 'Ab': 8, 'A': 9,
             'A#': 10, 'Bb': 10, 'B': 11}
    name = note_str[:-1]
    octave = int(note_str[-1])
    semitones = notes[name] + (octave - 4) * 12
    return 440.0 * (2.0 ** ((semitones - 9) / 12.0))

def sine_wave(freq, duration, phase=0.0):
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    return np.sin(2 * np.pi * freq * t + phase)

def triangle_wave(freq, duration):
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    return 2 * np.abs(2 * (t * freq - np.floor(t * freq + 0.5))) - 1

def marimba_tone(freq, duration):
    """Warm, woody plucked marimba/xylophone tone"""
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    env = np.exp(-12.0 * t)
    tone = (np.sin(2 * np.pi * freq * t) +
            0.35 * np.sin(2 * np.pi * freq * 2.0 * t) * np.exp(-18.0 * t) +
            0.15 * np.sin(2 * np.pi * freq * 3.0 * t) * np.exp(-24.0 * t) +
            0.08 * np.sin(2 * np.pi * freq * 4.0 * t) * np.exp(-30.0 * t))
    # Add woody strike attack
    noise = np.random.normal(0, 0.15, len(t)) * np.exp(-65.0 * t)
    return (tone + noise) * env

def bell_tone(freq, duration, decay=4.0):
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    s = (np.sin(2 * np.pi * freq * t) * np.exp(-decay * t) +
         0.4 * np.sin(2 * np.pi * freq * 2.04 * t) * np.exp(-decay * 1.5 * t) +
         0.2 * np.sin(2 * np.pi * freq * 3.01 * t) * np.exp(-decay * 2.2 * t) +
         0.1 * np.sin(2 * np.pi * freq * 4.15 * t) * np.exp(-decay * 3.0 * t))
    return s

def pluck_bass(freq, duration):
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    env = np.exp(-5.5 * t)
    tone = (np.sin(2 * np.pi * freq * t) +
            0.5 * np.sin(2 * np.pi * freq * 2.0 * t) * np.exp(-8.0 * t) +
            0.2 * triangle_wave(freq, duration) * np.exp(-10.0 * t))
    return tone * env

# ----------------- TITLE THEME BGM GENERATOR -----------------

def gen_bgm_title_theme():
    """Main Menu / Title Screen: Bouncy, cheerful, warm, uplifting school adventure theme (16s loop)"""
    dur = 16.0
    bpm = 120.0
    beat = 60.0 / bpm # 0.5s per beat
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    
    # 1. Bouncy Bassline (C - G - Am - F - C - G - F - C)
    # 4 beats per bar, 8 bars total (16 beats per 8s, 32 beats total for 16s)
    bass_prog = [
        ('C3', 'G2'), ('G2', 'D3'), ('A2', 'E3'), ('F2', 'C3'),
        ('C3', 'G2'), ('G2', 'D3'), ('F2', 'C3'), ('C3', 'G2'),
        ('C3', 'E3'), ('G2', 'B2'), ('A2', 'C3'), ('F2', 'A2'),
        ('C3', 'G2'), ('G2', 'D3'), ('F2', 'G2'), ('C3', 'C3')
    ]
    for bar_idx, (b_root, b_fifth) in enumerate(bass_prog):
        t_root = bar_idx * beat * 2
        t_fifth = t_root + beat
        if t_root + beat * 2 <= dur:
            # Root note on beat 1
            st1 = int(t_root * SAMPLE_RATE)
            f1 = note_to_freq(b_root)
            b1 = pluck_bass(f1, beat * 0.95) * 0.32
            end1 = min(st1 + len(b1), total_len)
            res[st1:end1, 0] += b1[:end1-st1]
            res[st1:end1, 1] += b1[:end1-st1]
            
            # Fifth note on beat 2
            st2 = int(t_fifth * SAMPLE_RATE)
            f2 = note_to_freq(b_fifth)
            b2 = pluck_bass(f2, beat * 0.95) * 0.28
            end2 = min(st2 + len(b2), total_len)
            res[st2:end2, 0] += b2[:end2-st2]
            res[st2:end2, 1] += b2[:end2-st2]

    # 2. Warm Ukulele / Acoustic Strumming on upbeats (and 1 & 2 & ...)
    chords_bars = [
        ['C4', 'E4', 'G4', 'C5'], ['G3', 'B3', 'D4', 'G4'],
        ['A3', 'C4', 'E4', 'A4'], ['F3', 'A3', 'C4', 'F4'],
        ['C4', 'E4', 'G4', 'C5'], ['G3', 'B3', 'D4', 'G4'],
        ['F3', 'A3', 'C4', 'F4'], ['C4', 'E4', 'G4', 'C5'],
        
        ['C4', 'E4', 'G4', 'C5'], ['G3', 'B3', 'D4', 'G4'],
        ['A3', 'C4', 'E4', 'A4'], ['F3', 'A3', 'C4', 'F4'],
        ['C4', 'E4', 'G4', 'C5'], ['G3', 'B3', 'D4', 'G4'],
        ['F3', 'A3', 'C4', 'D5'], ['C4', 'E4', 'G4', 'C5']
    ]
    for bar_idx, chord in enumerate(chords_bars):
        t_base = bar_idx * beat * 2
        # Strum on upbeat (0.5 beat and 1.5 beat)
        for offset_beat in [0.25, 0.75, 1.25, 1.75]:
            t_strum = t_base + offset_beat * beat
            if t_strum < dur:
                st = int(t_strum * SAMPLE_RATE)
                for c_idx, note in enumerate(chord):
                    f = note_to_freq(note)
                    # small arpeggio delay
                    st_note = st + int(c_idx * 0.012 * SAMPLE_RATE)
                    s_tone = sine_wave(f, 0.35) * np.exp(-12.0 * np.linspace(0, 0.35, int(SAMPLE_RATE * 0.35))) * 0.08
                    end = min(st_note + len(s_tone), total_len)
                    if st_note < total_len:
                        res[st_note:end, 0] += s_tone[:end-st_note] * 0.85
                        res[st_note:end, 1] += s_tone[:end-st_note] * 1.15

    # 3. Main Playful Melody (Marimba & Glockenspiel) - Two Sisters Theme!
    # Joyful, energetic melody
    melody_notes = [
        # Phrase 1: Jump & skip
        ('G4', 0.0, 0.3), ('E4', 0.25, 0.25), ('C4', 0.5, 0.4), ('D4', 1.0, 0.3), ('E4', 1.25, 0.3), ('G4', 1.5, 0.4),
        ('A4', 2.0, 0.3), ('G4', 2.25, 0.25), ('E4', 2.5, 0.35), ('C4', 3.0, 0.6),
        # Phrase 2: Catch me if you can!
        ('A4', 4.0, 0.25), ('B4', 4.25, 0.25), ('C5', 4.5, 0.35), ('G4', 5.0, 0.5),
        ('F4', 6.0, 0.25), ('E4', 6.25, 0.25), ('D4', 6.5, 0.4), ('C4', 7.0, 0.8),
        
        # Phrase 3: High spirits & harmony
        ('E5', 8.0, 0.25), ('D5', 8.25, 0.25), ('C5', 8.5, 0.35), ('G4', 9.0, 0.4),
        ('A4', 10.0, 0.25), ('C5', 10.25, 0.25), ('D5', 10.5, 0.35), ('E5', 11.0, 0.6),
        # Phrase 4: Happy school bell finish
        ('G5', 12.0, 0.35), ('E5', 12.5, 0.35), ('C5', 13.0, 0.4), ('D5', 13.5, 0.4),
        ('C5', 14.0, 1.2), ('E5', 14.2, 1.0), ('G5', 14.4, 0.9)
    ]
    for note, st_t, length in melody_notes:
        st = int(st_t * SAMPLE_RATE)
        f = note_to_freq(note)
        # Marimba wood core
        m = marimba_tone(f, length) * 0.36
        # Glockenspiel bell sparkle on top
        g = bell_tone(f * 2.0 if note[-1] < '5' else f, length, decay=9.0) * 0.16
        end = min(st + len(m), total_len)
        res[st:end, 0] += (m[:end-st] + g[:end-st]) * 0.95
        res[st:end, 1] += (m[:end-st] + g[:end-st]) * 1.05

    # 4. Cute Acoustic Percussion (Soft kick on 1, snare/clap on 2, shaker & woodblocks)
    for t_step in np.arange(0, dur, beat * 0.5):
        st = int(t_step * SAMPLE_RATE)
        beat_idx = int(round(t_step / beat))
        is_downbeat = (beat_idx % 2 == 0)
        
        # Soft cozy kick
        if is_downbeat and (st_step := int(t_step * SAMPLE_RATE)) < total_len:
            k_len = int(SAMPLE_RATE * 0.12)
            t_k = np.linspace(0, 0.12, k_len, endpoint=False)
            k_tone = np.sin(2 * np.pi * np.linspace(110, 45, k_len) * t_k) * np.exp(-32 * t_k) * 0.25
            k_end = min(st_step + k_len, total_len)
            res[st_step:k_end, 0] += k_tone[:k_end-st_step]
            res[st_step:k_end, 1] += k_tone[:k_end-st_step]
        else:
            # Woodblock click
            w_len = int(SAMPLE_RATE * 0.05)
            t_w = np.linspace(0, 0.05, w_len, endpoint=False)
            w_tone = np.sin(2 * np.pi * 880 * t_w) * np.exp(-75 * t_w) * 0.12
            w_end = min(st + w_len, total_len)
            res[st:w_end, 0] += w_tone[:w_end-st] * 1.1
            res[st:w_end, 1] += w_tone[:w_end-st] * 0.9

        # Gentle shaker on every 8th note
        sh_len = int(SAMPLE_RATE * 0.04)
        sh_noise = np.random.normal(0, 0.05, sh_len) * np.exp(-60 * np.linspace(0, 0.04, sh_len))
        sh_end = min(st + sh_len, total_len)
        res[st:sh_end, 0] += sh_noise[:sh_end-st]
        res[st:sh_end, 1] += sh_noise[:sh_end-st]

    # Master gentle compression
    res = np.clip(res, -0.92, 0.92)
    return res

# ----------------- SOUND EFFECTS (SFX) FOR MAIN MENU -----------------

def gen_sfx_game_start():
    """Joyful game start fanfare: bright ascending magical chime (C5-E5-G5-C6 arpeggio + sparkle)"""
    dur = 1.1
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    notes = ['C5', 'E5', 'G5', 'C6', 'E6', 'G6']
    times = [0.0, 0.09, 0.18, 0.28, 0.38, 0.48]
    for idx, (n, st_t) in enumerate(zip(notes, times)):
        st = int(st_t * SAMPLE_RATE)
        f = note_to_freq(n)
        tone = bell_tone(f, 0.6, decay=5.0) * 0.32
        end = min(st + len(tone), total_len)
        pan = 0.35 + 0.3 * (idx / len(notes))
        res[st:end, 0] += tone[:end-st] * (1 - pan)
        res[st:end, 1] += tone[:end-st] * pan
    # Golden shimmer tail
    t = np.linspace(0, dur, total_len, endpoint=False)
    shimmer = np.sin(2 * np.pi * 3800 * t) * np.sin(2 * np.pi * 24 * t) * np.exp(-3.0 * t) * 0.07
    res[:, 0] += shimmer
    res[:, 1] += shimmer
    return res

def gen_sfx_ui_click():
    """Clean, snappy, satisfying wooden UI click"""
    dur = 0.08
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    click = np.sin(2 * np.pi * 650 * t) * np.exp(-65 * t) * 0.45
    pop = np.sin(2 * np.pi * 1200 * t) * np.exp(-120 * t) * 0.25
    noise = np.random.normal(0, 0.1, len(t)) * np.exp(-140 * t)
    s = click + pop + noise
    return np.column_stack((s, s))

def gen_sfx_ui_hover():
    """Gentle, subtle wooden pop when hovering on buttons"""
    dur = 0.04
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    pop = np.sin(2 * np.pi * 840 * t) * np.exp(-110 * t) * 0.18
    return np.column_stack((pop, pop))

def gen_sfx_sister_cheer():
    """Playful double chime with sparkles when clicking on sisters or jumping together"""
    dur = 0.75
    total_len = int(SAMPLE_RATE * dur)
    res = np.zeros((total_len, 2))
    notes = ['F5', 'A5', 'C6', 'F6']
    times = [0.0, 0.07, 0.14, 0.22]
    for n, st_t in zip(notes, times):
        st = int(st_t * SAMPLE_RATE)
        f = note_to_freq(n)
        tone = marimba_tone(f, 0.45) * 0.35 + bell_tone(f, 0.45, decay=7.0) * 0.2
        end = min(st + len(tone), total_len)
        res[st:end, 0] += tone[:end-st]
        res[st:end, 1] += tone[:end-st]
    return res

if __name__ == '__main__':
    print("Generating Title Theme & Menu Audio...")
    write_wav('assets/audio/bgm/bgm_title_theme.wav', gen_bgm_title_theme())
    write_wav('assets/audio/sfx/sfx_game_start.wav', gen_sfx_game_start())
    write_wav('assets/audio/sfx/sfx_ui_click.wav', gen_sfx_ui_click())
    write_wav('assets/audio/sfx/sfx_ui_hover.wav', gen_sfx_ui_hover())
    write_wav('assets/audio/sfx/sfx_sister_cheer.wav', gen_sfx_sister_cheer())
    print("All Title Audio generated successfully!")
