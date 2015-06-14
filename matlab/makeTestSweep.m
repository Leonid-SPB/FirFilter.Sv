% This file is part of FirFilter.Sv (Trivial SystemVerilog implementation
% of FIR filters)
%
% Copyright (C) 2015  Leonid Azarenkov < leonid AT rezonics DOT com >
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
%
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUsigSS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

clear all
close all
clc
firFilter; %load firFilter parameters

%% Test signal, sweep
% change test signal parameters as necessary
Fs  = 10000;    % sampling freq, Hz
Ts  = 1/Fs;     % sampling period, s
dF  = Fs;       % sweep frequency range
Np  = Fs * 10;  % number of samples in test signal
Ttr = TapsNum;  % number of samples in transition period
dV  = dF/(Np);  % frequency step size, Hz

% scale factor for fixed point data
ZScaleFactor2 = 2^(DataBits - 1) - 1;

t = 0 : Ts : (Np - 1)*Ts;
v = 0 : dV : dF - dV;

% test signal
z_sig = exp(pi*1i*v.*t);
z_sig_fixp = round(z_sig * ZScaleFactor2);
z_sig_fixp = fi(z_sig_fixp, 1, DataBits, 0);

% filtered signal
y_sig = filter(FiltCoeffs, 1, z_sig);
y_sig_fixp = filter(FiltCoeffsFixP, 1, z_sig_fixp);
y_sig_fixp = fi(y_sig_fixp, 1, OutputBitsFullPrecision, 0);

figure(1)
title('Sweep wave test, real');
plot(t, real(z_sig_fixp), 'b');
hold on
plot(t, real(y_sig_fixp)/ScaleFactor2, 'g');
legend('original', 'filtered');

figure(2)
title('Sweep wave test, abs');
plot(v, abs(z_sig_fixp), 'b');
hold on
plot(v, abs(y_sig_fixp)/ScaleFactor2, 'g');
legend('original', 'filtered');

%save test signal and golden results
saveSignalFixp(SigFileRe, real(z_sig_fixp));
saveSignalFixp(SigFileIm, imag(z_sig_fixp));
saveSignalFixp(RefFileRe, real(y_sig_fixp));
saveSignalFixp(RefFileIm, imag(y_sig_fixp));