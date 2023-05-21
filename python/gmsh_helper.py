##############################
def calc_length(in_Npts,in_d,in_ratio):
    if(in_ratio==1):
        length=in_d*(in_Npts-1)
    else:
        length=in_d*(in_ratio**(in_Npts-1)-1)/(in_ratio-1)
    return length
##############################
def calc_npts_and_ratio(in_L,in_d,in_D):
    assert(in_L>0)
    from numpy import log
    if(in_D==in_d):
        ratio=1
        npts=in_L/in_d
    else:
        ratio=(in_L/in_d-1)/(in_L/in_d-in_D/in_d)
        npts=log(in_D/in_d)/log(ratio)+2
    return npts,ratio
##############################
def calc_ratio_func(in_r,in_L,in_Npts,in_d):
    res=0
    if(in_r==1):
        res=(in_Npts-1)*in_d-in_L
    else:
        res=in_d*((in_r**(in_Npts-1)-1)/(in_r-1))-in_L
    return res
def calc_ratio(in_L,in_Npts,in_d,ratio_0=1.1):
    assert(in_L>0)
    from scipy.optimize import root
    from numpy import abs
    sol=root(calc_ratio_func,ratio_0,args=(in_L,in_Npts,in_d),\
        method='hybr')
    ratio=sol.x[0]
    length=calc_length(in_Npts,in_d,ratio)
    if(abs(length-in_L) > 1E-9):
        sol=root(calc_ratio_func,ratio_0,args=(in_L,in_Npts,in_d),\
            method='lm')
        ratio=sol.x[0]
        length=calc_length(in_Npts,in_d,ratio)
        if(abs(length-in_L) > 1E-9):
            print("L=%e,L_calc=%e,N=%d,d=%e,r=%e"%(in_L,length,in_Npts,in_d,ratio))
            print(sol)
            from traceback import print_stack
            print_stack()
            exit()
    return ratio
##############################
def calc_npts(in_L,in_d,in_Ratio,in_npts_bin=[2,100]):
    if in_Ratio==1:
        npts=in_L/in_d+1
    else:
        from numpy import arange,ones,abs,argmin
        npts_arr=arange(in_npts_bin[1]-in_npts_bin[0]+1)+in_npts_bin[0]
        res_arr=ones(npts_arr.shape)*in_L/in_d
        for i in range(npts_arr.size):
            res_arr[i]=abs(res_arr[i]-(in_Ratio**(npts_arr[i]-1)-1)/(in_Ratio-1))
        npts=npts_arr[argmin(res_arr)]
    return npts


