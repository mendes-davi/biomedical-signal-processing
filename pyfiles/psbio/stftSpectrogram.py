import warnings
import matplotlib.pyplot as plt
import numpy as np
from numpy.fft import fft, fftshift
from matplotlib import rc
from .utils import reshapeOverlap

def stftSpectrogram(x, fs, win, loverlap=0, nfft=None, zeropad=False):
    rc('font', **{'size': 18, 'family': 'serif', 'serif': ['Arial']})
    nextpow2 = lambda x: 2**np.ceil(np.log2(np.abs(x)))
    if nfft is None:
        nfft = nextpow2(len(win))

    x = reshapeOverlap(x, len(win), int(loverlap), zeropad)
    spect_vals = lambda s: np.abs(fftshift(fft(win*s, nfft)))**2
    X = np.apply_along_axis(spect_vals, 0, x) # fft along axis 0 (cols)
    X = np.apply_along_axis(lambda col: col/np.max(col), 0, X) # normalize
    X = np.apply_along_axis(lambda col: 10*np.log10(col), 0, X) # db
    X = X[0:np.floor(X.shape[0]/2).astype('int')][:] # crop negative frequencies

    fig = plt.figure()
    plt.imshow(X, cmap='jet', extent=[0, 1, 0, 1], aspect='auto', interpolation='antialiased')
    plt.xlabel('Windows [{} samples - Tres {:.3f} ms]'.format(len(win), 1000*len(win)/fs))
    plt.ylabel('Frequency (Hz/sample) - [Fres {:.3f} Hz]'.format(fs/nfft))
    plt.colorbar(label='Energy/Frequency [dB/(Hz/sample)]')
    # Ticks
    nticks = np.ceil(nfft/64).astype('int')
    ticks = np.linspace(0, 1, nticks)
    plt.xticks(ticks, np.round(ticks*X.shape[1]).astype('int'))
    plt.yticks(ticks, np.round(ticks*fs/2))
    fig.show()

    return X
