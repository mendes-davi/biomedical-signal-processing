import warnings
import numpy as np


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
