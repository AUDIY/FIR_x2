# -*- coding: utf-8 -*-
"""
Created on Tue Jul  1 23:32:50 2025

@author: AUDIY
"""

# Import packages
import numpy as np
from scipy import signal
import matplotlib.pyplot as plt

# FIR filter  parameter
FC = 20000/44100
BIT = 16
TAPS = 512

# x2 Oversampling FIR filter generation by firwin
coef_float = signal.firwin(TAPS - 1, FC, window='hann') / 2

# Float to Integer
coef_int = np.int32(np.floor(((coef_float + 1)/2) * (2**(BIT + 1) - 1) + 0.5) - (2**BIT))
coef_int = np.insert(coef_int, 0, 0)

# Overflow Detection
Total_Odd = np.sum(coef_int[1::2])
Total_Even = np.sum(coef_int[0::2])
MAX_TOTAL = 2**(BIT - 2) - 1

print('Total of Odd taps :', Total_Odd, end='')
print(' [OK ( <= ' if Total_Odd <= MAX_TOTAL else ' [NG! ( > ', end='')
print(MAX_TOTAL, ')]')

print('Total of Even taps:', Total_Even, end='')
print(' [OK ( <= ' if Total_Even <= MAX_TOTAL else ' [NG! ( > ', end='')
print(MAX_TOTAL, ')]')

# Plot the original filter
plt.plot(coef_float)
plt.xlabel('Sample')
plt.ylabel('Magnitude')

# Save the Integer filter into .txt
FILE_NAME = './FIR_filter_512taps_16bit.txt'
np.savetxt(FILE_NAME, coef_int, fmt='%d')
