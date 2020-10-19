from numpy import pi, cos, sin, ones, arange, sqrt, real, min, concatenate, ceil, floor, minimum, flip, exp, log, linspace, cosh, arccosh

# Ported from tftb_window.m	Window generation.
#	yields a window of length N with a given shape.
#
#	N      : length of the window
#	NAME   : name of the window shape (default : Hamming)
#	PARAM  : optional parameter
#	PARAM2 : second optional parameters
#
#	Possible windows are :
#	'Hamming', 'Hanning', 'Nuttall',  'Papoulis', 'Harris',
#	'Rect',    'Triang',  'Bartlett', 'BartHann', 'Blackman'
#	'Gauss',   'Parzen',  'Kaiser',   'Dolph',    'Hanna'.
#	'Nutbess', 'spline',  'Flattop'
#
#	For the gaussian window, an optionnal parameter K
#	sets the value at both extremities. The default value is 0.005
#
#	For the Kaiser-Bessel window, an optionnal parameter
#	sets the scale. The default value is 3*pi.
#
#	For the Spline windows, h=tftb_window(N,'spline',nfreq,p)
#	yields a spline weighting function of order p and frequency
#	bandwidth proportional to nfreq.

def rect(N):
    return ones([N])

def hamming(N):
    return 0.54 - 0.46*cos(2.0*pi/(N+1)*arange(1, N+1, 1))

def hanning(N):
    return 0.50 - 0.50*cos(2.0*pi/(N+1)*arange(1, N+1, 1))

def kaiser(N, beta=3*pi):
    from scipy.special import jv as besselj
    ind = arange(-(N-1)/2, 1+(N-1)/2, 1)*2/N
    return real(besselj(0, 1j*beta*sqrt(1.0-ind**2)))/real(besselj(0, 1j*beta))

def nuttall(N):
    ind = arange(-(N-1)/2, 1+(N-1)/2, 1)*2.0*pi/N
    h = +0.3635819 \
        +0.4891775*cos(ind) \
        +0.1363995*cos(2.0*ind) \
        +0.0106411*cos(3.0*ind)
    return h

def blackman(N):
    ind = arange(-(N-1)/2, 1+(N-1)/2, 1)*2.0*pi/N
    return 0.42 + 0.50 * cos(ind) + 0.08 * cos(2.0*ind)

def harris(N):
    ind = arange(1, N+1) * 2.0*pi/(N+1)
    h = +0.35875 \
        -0.48829*cos(ind) \
        +0.14128*cos(2.0*ind) \
        -0.01168*cos(3.0*ind)
    return h

def bartlett(N): # triangular window
    ind = concatenate((arange(1, ceil((N+1)/2), 1), arange(ceil(N/2), 1-1, -1)))
    return 2.0*ind/(N+1)

def barthann(N):
    ind = arange(1, N+1)/(N+1)
    h = + 0.38 * (1 - cos(2.0*pi*ind)) + \
        + 0.48 * minimum(ind, flip(ind))
    return h

def papoulis(N):
    ind = arange(1, N+1) * pi/(N+1)
    return sin(ind)

def gauss(N, K=0.005):
    return exp(log(K) * linspace(-1, 1, N)**2)

def parzen(N):
    ind = abs(arange(-(N-1)/2, N/2, 1)) * 2/N
    tmp = 2 * (1 - ind)**3
    return minimum(tmp - (1 - 2.0 * ind)**3, tmp)

def hanna(N, L=1):
    ind = arange(0, N)
    return sin((2*ind+1)*pi/(2*N))**(2*L)

def dolph(N, p=-60):
    if N % 2 == 0:
        oddN = 1
        N = 2 * N + 1
    else:
        oddN = 0
    A = 10**(p/20)
    K = N - 1
    Z0 = cosh(arccosh(1.0/A)/K)
    x0 = arccosh(1/Z0)/pi
    x = arange(0, N)/N
    ind1 = (x < x0) | (x > 1-x0)
    ind2 = (x >= x0) & (x <= 1-x0)
    return ind1, ind2

# TODO: DOLPH
# TODO: NUTBESS
# TODO: SPLINE
# TODO: FLATTOP
