import numpy as np

def daub(N):
    """
    Ported from wfilt_db.m in LTFAT
    wfiltDb    Daubechies FIR filterbank
       [H,G] = dbfilt(N) computes a two-channel Daubechies FIR filterbank
       from prototype maximum-phase analysing lowpass filter obtained by
       spectral factorization of the Lagrange interpolator filter.  N also
       denotes the number of zeros at z=-1 of the lowpass filters of length
       2N.  The prototype lowpass filter has the following form (all roots of
       R(z) are outside of the unit circle):

          H_l(z)=(1+z^-1)^N*R(z),

       where R(z) is a spectral factor of the Lagrange interpolator P(z)=2R(z)*R(z^{-1})
       All subsequent filters of the two-channel filterbank are derived as
       follows:

          H_h(z)=H_l((-z)^-1)
          G_l(z)=H_l(z^-1)
          G_h(z)=-H_l(-z)

       making them an orthogonal perfect-reconstruction QMF.
    """

    # Calculating Lagrange interpolator coefficients
    sup = np.arange(-N+1, N+1)
    a = np.zeros([N])
    for n in range(1, N+1):
        non = sup[sup != n]
        a[n-1] = np.prod(0.5-non)/np.prod(n-non)
    P = np.zeros([2*N-1])
    P[::2] = a
    P = np.concatenate((P[::-1], [1], P))

    R = np.roots(P)
    # Roots outside of the unit circle and in the right halfplane
    R = R[np.where((np.abs(R) < 1) & (np.real(R) > 0))]

    # Roots of the 2*conv(lo_a, lo_r) filter
    hroots = np.concatenate((R, -np.ones([N])))

    h = []
    # Building synthetizing low-pass filter from roots
    h.append(np.real(np.poly(np.sort(hroots))))
    h[0] = h[0]/np.linalg.norm(h[0])
    # QMF modulation lowpass -> highpass
    h.append((-1)**(np.arange(0, 2*N))*h[0][::-1])

    # The reverse is here, because we use different convention for
    # filterbanks than in Ten Lectures on Wavelets
    h[0] = h[0][::-1]
    h[1] = h[1][::-1]

    Lh = len(h[0])
    # Default offset
    d = list(map(lambda hEl: -len(hEl)/2, h))
    if N > 2:
        # Do a filter alignment according to "center of gravity"
        aLh = np.arange(1, Lh+1)
        d[0] = -np.floor(np.sum(aLh * np.abs(h[0])**2)/np.sum(np.abs(h[0])**2))
        d[1] = -np.floor(np.sum(aLh * np.abs(h[1])**2)/np.sum(np.abs(h[1])**2))
        if (d[0]-d[1]) % 2 == 1:
            d[1] += 1

    # Format filters
    h0, h1 = h
    g0, g1 = h[0][::-1], h[1][::-1]
    return h0, h1, g0, g1, d
