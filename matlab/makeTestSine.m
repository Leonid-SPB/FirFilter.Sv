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
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

clear all
close all
clc
firFilter; %load firFilter parameters

%% Make test signal, sine
% change test signal parameters as necessary
Fs = 10000; % sampling frequency, Hz
Ts = 1/Fs;  % sampling period, s
Np = 1000;  % number of samples in test signal
v  = 50;    % test signal frequency, Hz

% scale factor for fixed point data
ZScaleFactor2 = 2^(DataBits - 1) - 1;

t = 0 : Ts : (Np - 1)*Ts;


% test signal
z_sine = exp(2*pi*1i*v*t);
z_sine_fixp = round(z_sine * ZScaleFactor2);
z_sine_fixp = fi(z_sine_fixp, 1, DataBits, 0);

% filtered signal
y_sine = filter(FiltCoeffs, 1, z_sine);
y_sine_fixp = filter(FiltCoeffsFixP, 1, z_sine_fixp);
y_sine_fixp = fi(y_sine_fixp, 1, OutputBitsFullPrecision, 0);

figure(1)
title('Sine wave test');
plot(t, real(z_sine_fixp), 'b');
hold on
plot(t, real(y_sine_fixp)/ScaleFactor2, 'g');
legend('original', 'filtered');

%save test signal and golden results
saveSignalFixp(SigFileRe, real(z_sine_fixp));
saveSignalFixp(SigFileIm, imag(z_sine_fixp));
saveSignalFixp(RefFileRe, real(y_sine_fixp));
saveSignalFixp(RefFileIm, imag(y_sine_fixp));