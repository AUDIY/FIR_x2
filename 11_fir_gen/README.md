# Introduction to FIR Filter Generation

This document describes the example process of creating a custom FIR (Finite Impulse Response) filter using Python, converting the coefficients into signed integers, and formatting them for use in FIR_x2.

## 1. Generate FIR Filter Coefficients

Use Python (or MATLAB) to generate the floating-point FIR filter coefficients. The provided script `fir_gen.py` demonstrates how to:

- Design a low-pass FIR filter using `scipy.signal.firwin`
- Apply a Hann window
- Use a cutoff frequency of 20 kHz for a 44.1 kHz sampling rate
- Set the number of taps (coefficients) to 512 (must be even)
- Convert the floating-point coefficients to signed integers using 2's complement representation

```python
coef_float = signal.firwin(TAPS - 1, FC, window='hann') / 2
coef_int = np.int32(np.floor(((coef_float + 1)/2) * (2**(BIT + 1) - 1) + 0.5) - (2**BIT))
```

## 2. Ensure Even Number of Coefficients

Hardware implementations require the number of FIR coefficients to be even. If the generated coefficient count is odd, prepend a zero:

```python
coef_int = np.insert(coef_int, 0, 0)
```

This ensures proper alignment and supports optimized hardware filter designs.

## 3. Convert to Hexadecimal Format

To make the coefficients usable in hardware systems, convert the decimal values into hexadecimal format using 2's complement representation. A sample AWK script `dec2hex.awk` is provided.

### Requirements:
- Signed 2's complement hexadecimal format
- Configurable hex digit width (e.g., 4 digits for 16 bits)
- Output file should have a `.data` extension

### Example Conversion Command:

```bash
awk -v width=4 -v out="FIR_filter.data" -f dec2hex.awk FIR_filter_512taps_16bit.txt
```

This converts the decimal coefficients from the `.txt` file to a `.data` file with hexadecimal values suitable for hardware initialization.
