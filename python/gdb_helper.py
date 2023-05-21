def hex_to_float(hex_str,nbits):
    if (hex_str[:2] == '0x'):
        hex_str = hex_str[2:]
    if (nbits == 64):
        n_exp=12
        n_frac=52
        exp_offset=1023
    elif (nbits == 128):
        n_exp=16
        n_frac=112
        exp_offset=16383
    int_val = int(hex_str,16)
    bin_str = bin(int_val)
    bin_str = bin_str[2:]
    sign = int(bin_str[0],2)
    exponent = int(bin_str[1:n_exp],2)
    fraction_bin_str = bin_str[n_exp:][::-1]
    frac = 0
    for i in range(1,n_frac+1):
        frac += int(fraction_bin_str[n_frac-i],2) * 2**(-i)
    f = (-1)**sign * (frac+1) * 2**(exponent-exp_offset)
    return f

