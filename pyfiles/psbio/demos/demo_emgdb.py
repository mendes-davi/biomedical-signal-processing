#!/usr/bin/python3
import psbio as ps
import numpy as np
import matplotlib.pyplot as plt
import json

if __name__ == '__main__':
    plt.close("all")

    records = ['emgdb_healthy', 'emgdb_myopathy', 'emgdb_neuropathy']
    records_path = '../datasets/'
    emg_rec = []
    emg = []

    for n, rec in enumerate(records):
        with open(records_path+rec+'.json', 'r') as f:
            emg_rec.append(json.loads(f.read()))
            emg.append(np.array(emg_rec[n]['p_signal']).flatten())
    fs = emg_rec[n]['fs']

    # Healthy EMG
    N = 512
    win = ps.utils.blackman(N)
    loverlap = N/8
    nfft = 1024
    ps.stftSpectrogram(emg[0], fs, win, loverlap, nfft, zeropad=True)
    plt.title('Healthy')

    # Myopathy
    ps.stftSpectrogram(emg[1], fs, win, loverlap, nfft, zeropad=True)
    plt.title('Myopathy')

    # Neuropathy
    ps.stftSpectrogram(emg[2], fs, win, loverlap, nfft, zeropad=True)
    plt.title('Neuropathy')

    plt.show()
