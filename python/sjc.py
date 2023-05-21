###########################################################
# Function library created by Shi Jingchang.
# Date: 2017-03-28, 15:23:34
###########################################################
#==========================================================
# FFT
#==========================================================
def fft(in_u, in_sample_freq):
    from numpy.fft import fft, fftfreq, fftshift
    #  from numpy import mean
    #  in_u = in_u - mean(in_u)
    dx = 1.0 / in_sample_freq
    nx = in_u.size
    out_freq = fftfreq(nx, dx)
    out_fft = fft(in_u)/nx
    out_freq = fftshift(out_freq)
    out_fft = fftshift(out_fft)
    return out_freq, out_fft

def fftavg(in_u_arr, in_sample_freq, in_n_segment, in_npts_in_segment):
    from numpy import floor,mean,zeros,hanning
    if(in_npts_in_segment%2==0): # even
        half_npts_in_segment=int(in_npts_in_segment/2)
    else: # odd
        half_npts_in_segment=int(floor(in_npts_in_segment/2))
    npts_required=(in_n_segment+1)*half_npts_in_segment
    if(npts_required>in_u_arr.size):
        print("The number of points required by the segments is %d"%npts_required)
        print("The number of points available is %d"%in_u_arr.size)
        exit("Reassign the number of segments to do averaging.")
    in_u_arr = in_u_arr - mean(in_u_arr)
    #  print("data subsection length:", in_npts_in_segment)
    #  in_n_segment = int(in_u_arr.size/in_npts_in_segment)
    #  print("number of subsection:", in_n_segment)
    shift_factor=0.5
    #  npts_in_shift = (in_u_arr.size-in_npts_in_segment)/in_n_segment
    npts_in_shift=int(floor(shift_factor*in_npts_in_segment))
    #  print("subsection shift length:", npts_in_shift)
    #  print("data used/avail:", npts_required, "/", in_u_arr.size)
    u_sub_freq = zeros((in_npts_in_segment,))
    u_sub_fft = zeros((in_npts_in_segment,),dtype="complex128")
    for i in range(in_n_segment):
        u_sub = in_u_arr[i*npts_in_shift:in_npts_in_segment+i*npts_in_shift]
        u_sub = u_sub * hanning(u_sub.size)
        tmp1, tmp2 = fft(u_sub, in_sample_freq)
        u_sub_freq += tmp1
        u_sub_fft  += tmp2
    u_sub_freq /= in_n_segment
    u_sub_fft /= in_n_segment
    #  print("Note: hanning window function is used.")
    return u_sub_freq, u_sub_fft.real

def psd(in_u, in_sample_freq):
    from numpy.fft import fft, fftfreq, fftshift
    from numpy import conj, mean
    in_u = in_u - mean(in_u)
    dx = 1.0 / in_sample_freq
    nx = in_u.size
    out_freq = fftfreq(nx, dx)
    u_fft = fft(in_u)
    out_psd = u_fft * conj(u_fft) / ((nx/2)**2)
    #  out_psd = u_fft * conj(u_fft)
    out_freq = fftshift(out_freq)
    out_psd = fftshift(out_psd)
    return out_freq, out_psd

def psdavg(in_u_arr, in_sample_freq, in_n_segment, in_npts_in_segment):
    from numpy import floor,mean,zeros,hanning
    if(in_npts_in_segment%2==0): # even
        half_npts_in_segment=int(in_npts_in_segment/2)
    else: # odd
        half_npts_in_segment=int(floor(in_npts_in_segment/2))
    npts_required=(in_n_segment+1)*half_npts_in_segment
    if(npts_required>in_u_arr.size):
        print("The number of points required by the segments is %d"%npts_required)
        print("The number of points available is %d"%in_u_arr.size)
        exit("Reassign the number of segments to do averaging.")
    in_u_arr = in_u_arr - mean(in_u_arr)
    #  print("data subsection length:", in_npts_in_segment)
    #  in_n_segment = int(in_u_arr.size/in_npts_in_segment)
    #  print("number of subsection:", in_n_segment)
    shift_factor=0.5
    #  npts_in_shift = (in_u_arr.size-in_npts_in_segment)/in_n_segment
    npts_in_shift=int(floor(shift_factor*in_npts_in_segment))
    #  print("subsection shift length:", npts_in_shift)
    #  print("data used/avail:", npts_required, "/", in_u_arr.size)
    u_sub_freq = zeros((in_npts_in_segment,))
    u_sub_psd = zeros((in_npts_in_segment,),dtype="complex128")
    for i in range(in_n_segment):
        u_sub = in_u_arr[i*npts_in_shift:in_npts_in_segment+i*npts_in_shift]
        u_sub = u_sub * hanning(u_sub.size)
        tmp1, tmp2 = psd(u_sub, in_sample_freq)
        u_sub_freq += tmp1
        u_sub_psd  += tmp2
    u_sub_freq /= in_n_segment
    u_sub_psd /= in_n_segment
    #  print("Note: hanning window function is used.")
    return u_sub_freq, u_sub_psd.real

def calc_spectra(in_t_arr,in_u_arr,in_t_seg,in_n_seg,in_skip,in_method):
    from numpy import zeros,diff
    t_cut=in_t_arr[-1]-in_t_seg/2*(in_n_seg+1)
    idx_cut=in_t_arr>t_cut
    t_arr_cut=in_t_arr[idx_cut]
    if t_arr_cut.size%2==1:
        t_arr_cut=t_arr_cut[1:]
        u_arr_cut=in_u_arr[idx_cut][1:]
    else:
        u_arr_cut=in_u_arr[idx_cut]
    npts_in_segment=int((t_arr_cut[::in_skip].size/(in_n_seg+1))*2)
    u_spec=zeros((npts_in_segment,))
    for i_skip in range(in_skip):
        t_arr=t_arr_cut[i_skip::in_skip]
        u_arr=u_arr_cut[i_skip::in_skip]
        dt_arr=diff(t_arr)
        dt=dt_arr[0]
        fs=1.0/dt
        if in_method=="fft":
            u_freq,u_spec_tmp=fftavg(u_arr,fs,in_n_seg,npts_in_segment)
        elif in_method=="psd":
            u_freq,u_spec_tmp=psdavg(u_arr,fs,in_n_seg,npts_in_segment)
        u_spec+=u_spec_tmp/in_skip
    return u_freq,u_spec

#  def calc_spectra_pre(in_t_arr):
    #  npts=in_t_arr.size
    #  print("")
    #  dt_arr=diff(in_t_arr)
    #  dt=dt_arr[0]
    #  fs=1.0/dt
    #  print("")
    #  t_span=in_t_arr[-1]-in_t_arr[0]
    #  print("")


#  def fft(in_u, in_freq_sample):
    #  from numpy.fft import fft as npfft
    #  from numpy import conj, arange, floor
    #  u_fft = npfft(in_u)
    #  n_x = in_u.size
    #  psd = conj(u_fft) * u_fft / (n_x/2.0)**2
    #  # from numpy.fft import fftfreq
    #  # dx = 1.0 / in_freq_sample
    #  # freq = fftfreq(n_x, dx)
    #  # # it's the same as the above method
    #  freq = arange(0, floor(n_x/2)+1, 1) * in_freq_sample / n_x
    #  return freq, psd
#==========================================================
# POD
#==========================================================
def get_pod(in_data):
    from numpy import load, diag
    from numpy.linalg import svd
    out_u, out_s, out_v = svd(in_data, full_matrices=0, compute_uv=1)
    return out_u, out_s, out_v

def get_pod_mode(in_u, in_s, in_v, in_ind_mode):
    tmp1 = in_u[:, in_ind_mode] * in_s[in_ind_mode]
    tmp2 = in_v[in_ind_mode, :]
    out_pod_mode = tmp1.reshape((tmp1.size,1)) * tmp2.reshape((1, tmp2.size))
    return out_pod_mode

def get_pod_timecoe(in_v, in_ind_mode):
    out_pod_timecoe = in_v[in_ind_mode, :]
    return out_pod_timecoe

#==========================================================
# DMD
#==========================================================
def get_dmd(in_data):
    from numpy.linalg import svd
    from numpy import dot
    from numpy.linalg import inv
    from numpy import diag
    from numpy.linalg import eig
    n_t = in_data.shape[1]
    v_1_n1 = in_data[:, 0:n_t-1]
    v_2_n = in_data[:, 1:n_t]
    svd_u, svd_s, svd_w = svd(v_1_n1, full_matrices=0)
    companion_s = dot(svd_u.T, v_2_n)
    companion_s = dot(companion_s, svd_w.T)
    companion_s = dot(companion_s, inv(diag(svd_s)))
    eig_w, eig_v = eig(companion_s)
    dmd_eigval = eig_w
    dmd_eigvec = dot(svd_u, eig_v)
    return dmd_eigval, dmd_eigvec

#==========================================================
# Turbulence Spectra 1D
#==========================================================
def get_turbulence_spectra_1d(in_u, in_nu):
    from numpy.fft import fft
    from numpy.fft import ifft
    from numpy import conj
    from numpy import abs
    from numpy import arange
    from numpy import sum
    from numpy import floor
    n = in_u.size
    u_fft = fft(in_u)
    Phi_u = conj(u_fft) * u_fft / n
    # R_u = ifft(Phi_u)
    E_u = 0.5 * abs(Phi_u)
    k = arange(E_u.size)
    varepsilon = sum(2.0 * in_nu * k**2 * E_u)
    eta = (in_nu**3.0 / varepsilon)**(1.0/4.0)
    out_k_eta = k * eta
    out_E_u_scale = E_u / (varepsilon * in_nu**5.0)**(1.0/4.0)
    out_n_half = arange(int(floor(E_u.size / 2.0)))
    return out_k_eta, out_E_u_scale, out_n_half

def get_turbulence_spectra_1d_standard(in_k_eta):
    out_k_eta2 = in_k_eta[1:]
    out_EIS = 18.0/55.0 * 1.6 * out_k_eta2**(-5.0/3.0)
    return out_k_eta2, out_EIS

def plot_turbulence_spectra_1d(in_fig_name, in_k_eta, in_E_u_scale, in_n_half,
        in_flag_compare=0):
    import matplotlib.pyplot as plt
    plt.style.use(["ggplot"])
    fig = plt.figure()
    ax = fig.gca()
    ax.loglog(in_k_eta[in_n_half], in_E_u_scale[in_n_half], "-", label="Real Data")
    if in_flag_compare == 1:
        k_eta2, EIS = get_turbulence_spectra_1d_standard(in_k_eta)
        ax.loglog(k_eta2[in_n_half], EIS[in_n_half], label="Formula")
    ax.legend()
    ax.set_xlabel(r"$k_{\eta}$")
    ax.set_ylabel(r"$E(u) / (\varepsilon \nu^{5})^{1/4}$")
    # xlim = [in_k_eta[in_n_half].min(), in_k_eta[in_n_half].max()]
    # ax.set_xlim(xlim)
    ax.set_title("Turbulence Spectra 1D")
    plt.tight_layout()
    fig.savefig(in_fig_name)
    plt.clf()

def get_2pts_autocor(vel_vec):
    from numpy import mean, conj
    from numpy.fft import fft, ifft
    vel_vec = vel_vec - mean(vel_vec)
    n_vel_vec = vel_vec.size
    #  vel_fft = fft(vel_vec, n_vel_vec*2)
    vel_fft = fft(vel_vec)
    Phi_vel = conj(vel_fft) * vel_fft / n_vel_vec
    R_u_fft = ifft(Phi_vel)
    R_u_fft /= mean(vel_vec**2)
    return R_u_fft
#==========================================================
# Plot Functions
#==========================================================
def plot_1d_line(in_fig_name, in_x, in_u,
        in_title=[], in_xlabel=[], in_ylabel=[], in_line_properties=[],
        in_xlim=[], in_n_xticks=3, in_ylim=[], in_n_yticks=3):
    import matplotlib.pyplot as plt
    plt.style.use('sjc')
    from numpy import linspace
    from numpy import round
    fig = plt.figure()
    ax = fig.gca()
    ax.plot(in_x, in_u)
    if in_xlim == []:
        in_xlim = [in_x.min(), in_x.max()]
    ax.set_xlim(in_xlim[0], in_xlim[1])
    ax.set_xticks(linspace(in_xlim[0], in_xlim[1], in_n_xticks))
    if in_ylim == []:
        in_ylim = [in_u.min(), in_u.max()]
    ax.set_ylim(in_ylim[0], in_ylim[1])
    ax.set_yticks(linspace(in_ylim[0], in_ylim[1], in_n_yticks))
    ax.set_title(in_title)
    ax.set_xlabel(in_xlabel)
    ax.set_ylabel(in_ylabel)
    plt.tight_layout()
    fig.savefig(in_fig_name)
    plt.clf()

#==========================================================
# gas dynamics
#==========================================================
def U2V(in_U):
    from numpy import array
    GAMMA=1.4
    if in_U.size == 4:
        DIM=2
    elif in_U.size == 5:
        DIM=3
    if DIM==2:
        rho = in_U[0]
        u = in_U[1] / rho
        v = in_U[2] / rho
        p = (GAMMA-1.0)*(in_U[3]-0.5*rho*(u*u+v*v))
        out_V = array([rho, u, v, p])
    elif DIM==3:
        rho = in_U[0]
        u = in_U[1] / rho
        v = in_U[2] / rho
        w = in_U[3] / rho
        p = (GAMMA-1.0)*(in_U[4]-0.5*rho*(u*u+v*v+w*w))
        out_V = array([rho, u, v, w, p])
    return out_V

#==========================================================
# matplotlib
#==========================================================
from collections import OrderedDict

linestyles = OrderedDict([
    ('solid',               (0, ())),

    ('loosely dotted',      (0, (1, 10))),
    ('dotted',              (0, (1, 5))),
    ('densely dotted',      (0, (1, 1))),

    ('loosely dashed',      (0, (5, 10))),
    ('dashed',              (0, (5, 5))),
    ('densely dashed',      (0, (5, 1))),

    ('loosely dashdotted',  (0, (3, 10, 1, 10))),
    ('dashdotted',          (0, (3, 5, 1, 5))),
    ('densely dashdotted',  (0, (3, 1, 1, 1))),

    ('loosely dashdotdotted', (0, (3, 10, 1, 10, 1, 10))),
    ('dashdotdotted',         (0, (3, 5, 1, 5, 1, 5))),
    ('densely dashdotdotted', (0, (3, 1, 1, 1, 1, 1)))
    ])

