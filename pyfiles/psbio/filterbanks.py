import numpy as np
from numpy import convolve as conv

def alternateCoefficientsSignals(h):
    h0_ = np.array(h)
    h0_[1:len(h0_):2] = -h0_[1:len(h0_):2]
    return list(h0_)

def polySum(x, y):
    x1 = np.zeros(max(len(x), len(y)))
    y1 = np.copy(x1)
    x1[:len(x)] = x
    y1[:len(y)] = y
    z = x1 + y1
    return z

def downsample(x, factor):
    x = x[:len(x):factor]
    return x

def upsample(x, factor):
    y = np.zeros(len(x)*factor)
    y[:len(y):factor] = x
    return y

def evaluateDecompositionSynthesisFilters(h0, h1, g0, g1, tol=1e-4):
    h0_ = alternateCoefficientsSignals(h0)
    h1_ = alternateCoefficientsSignals(h1)
    alias_term = polySum(conv(h0_, g0), conv(h1_, g1))
    perfect_reconstruction = bool(np.sum(np.where(alias_term < tol, 0, alias_term)) == 0)
    lti_term = polySum(conv(h0, g0), conv(h1, g1))
    # TODO: Handle edge cases (approximate reconstruction)
    k = int(list(np.where(np.abs(lti_term) >= tol))[0])
    A = float(lti_term[k]/2.0)
    return perfect_reconstruction, A, k

def filterIterator(h0, h1, levels):
    h0 = np.array(h0)
    h1 = np.array(h1)
    h = [0] * (levels+1)
    h[levels] = h1
    aux = np.copy(h0)
    for n in range(levels, 1, -1):
        h_ = upsample(h[n], 2)
        h_ = h_[:len(h_) - 1]
        h[n-1] = conv(h_, h0)
        aux = upsample(aux, 2)
        aux = aux[:len(aux) - 1]
        aux = conv(aux, h0)
    h[0] = aux
    return h

def qmfDecomposition(x, h0, h1, levels):
    h = filterIterator(h0, h1, levels)
    xdc = [0] * (levels + 1)
    xd = []
    downsample_factor = 1
    for n in range(levels, 0, -1):
        downsample_factor *= 2
        xdc[n] = downsample(conv(h[n], x), downsample_factor)
        xd = np.append(xdc[n], xd)
    xdc[0] = downsample(conv(h[0], x), downsample_factor)
    return xdc, xd

def qmfReconstruction(xdc, h0, h1, g0, g1):
    N1 = len(xdc[len(xdc)-1])
    levels = len(xdc)-1
    [_, A, d] = evaluateDecompositionSynthesisFilters(h0, h1, g0, g1)

    g = filterIterator(g0, g1, levels)
    compensatory_delay = d
    upsample_factor = 2**levels

    for n in range(2):
        xdc[n] = upsample(xdc[n], upsample_factor)
        xdc[n] = xdc[n][0 : len(xdc[n])-upsample_factor+1]
        xdc[n] = conv(g[n], xdc[n])
    for n in range(2, levels+1):
        xdc[n] = np.append(np.zeros([compensatory_delay]), xdc[n])
        compensatory_delay = int(compensatory_delay + 2**(n-1)*d)
        upsample_factor = int(upsample_factor/2)
        xdc[n] = upsample(xdc[n], upsample_factor)
        xdc[n] = xdc[n][0 : len(xdc[n])-upsample_factor+1]
        xdc[n] = conv(g[n], xdc[n])

    signal_length = max(map(len, xdc))
    xdelay = np.zeros([signal_length])
    for n in range(levels+1):
        xdelay = xdelay + np.append(xdc[n], np.zeros([signal_length-len(xdc[n])]))
    xdelay = xdelay/A
    rx = xdelay[compensatory_delay:]

    N = 2*N1 - len(h1)
    rx = rx[:N]
    return rx
