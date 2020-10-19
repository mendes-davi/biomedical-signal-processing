#!/usr/bin/python3

import warnings
import matplotlib.pyplot as plt
import numpy as np
from numpy.fft import fft, fftshift
from matplotlib import rc

rc('font',**{'size':18, 'family':'serif','serif':['Arial']})

def chirpGenerator(amp, duration, fs, chirp_fun):
    t = np.arange(0, duration, 1/fs)
    x = amp * np.sin(2*np.pi * chirp_fun(t)*t)
    return x, t

def reshapeOverlap(x, lwin, loverlap=0, zeropad=True):
    if zeropad:
        n_win = np.ceil((len(x)-lwin)/(lwin-loverlap)).astype('int')
        pad_size = int(n_win*(lwin-loverlap)+lwin - len(x))
        x = np.append(x, np.zeros([pad_size]), 0)
        if pad_size > 0:
            warnings.warn('Zero Padding in {} elements'.format(pad_size))
    else:
        n_win = np.floor((len(x)-lwin)/(lwin-loverlap)).astype('int')
        missed_elements = np.ceil((len(x)-lwin)/(lwin-loverlap))*(lwin-loverlap)+lwin - len(x)
        if missed_elements > 0:
            warnings.warn('Missed {} samples because Zero Padding is false'.format(missed_elements))

    ov_x = np.zeros([lwin, n_win+1])
    for n in range(0, n_win+1, 1):
        strp = n*(lwin-loverlap)
        ov_x[:, n] = x[strp : strp+lwin]

    return ov_x

def stftSpectrogram(x, fs, win, loverlap=0, nfft=None, zeropad=False):
    if nfft is None:
        nfft = len(win)

    x = reshapeOverlap(x, len(win), int(loverlap), zeropad)
    spect_vals = lambda s: 10*np.log10(np.abs(fftshift(fft(win*s, nfft)))**2)
    X = np.apply_along_axis(spect_vals, 0, x)
    X = X[0:np.floor(X.shape[0]/2).astype('int')][:]

    fig = plt.figure()
    plt.imshow(X, cmap='jet', extent=[0, 1, 0, 1], aspect='auto', interpolation='antialiased')
    plt.xlabel('Windows [{} samples - Tres {:.3f} ms]'.format(len(win), 1000*len(win)/fs))
    plt.ylabel('Frequency (Hz/sample) - [Fres {:.3f} Hz]'.format(fs/nfft))
    plt.colorbar(label='Energy/Frequency [dB/(Hz/sample)]')
    # Ticks
    nticks = np.ceil(X.shape[1]/5).astype('int')
    ticks = np.linspace(0, 1, nticks)
    plt.xticks(ticks, np.round(ticks*X.shape[1]).astype('int'))
    plt.yticks(ticks, np.round(ticks*fs/2))
    fig.show()

    return X

def main():
    plt.close("all")  # close all figures

    # Generate Chirp Signal
    fs = 2048
    chirp_fun = lambda x: 20*x
    x, t = chirpGenerator(10, 8, fs, chirp_fun)

    # Plot Chirp Signal
    plt.figure()
    plt.title('Chirp Signal')
    plt.plot(t, x)

    # Spectrogram
    win = np.ones([256])
    stftSpectrogram(x, fs, win, loverlap=len(win)/4, nfft=1024, zeropad=True)

    # Show Plots
    plt.ion()  # plotting in a non-blocking way
    plt.tight_layout()
    plt.show()
    plt.waitforbuttonpress()


if __name__ == '__main__':
    main()
