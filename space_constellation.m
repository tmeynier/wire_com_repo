
% Passband modulation and demodulation matlab demo
% Square-root Raised cosine rolloff pulse used as p^b(t)

clear
close all
clc
rng('default'); % Set seed for random number generator (for repeatability of simulation)

% Parameters
IsMultipath = false; % false for AWGN channel, true for multipath channel

LL = 1000; % Total number of bits
T = 1; % Symbol period in microsec
N = 21; % length of filter in symbol periods
alpha = 0.2; % alpha of sqrt raised cosine filter
fc = 5; % Carrier Frequency in MHz
fs = 100; % Sampling frequency in MHz
sigma_n = 2; % Noise standard deviation
phaseoffset = 0*pi/3; % Phase offset in transmitter carrier. Try 0*pi/3 and pi/3
frequencyoffsetfraction = 0e-6; % Frequency offset in receiver carrier/carrier frequency. Try 0e-6 and 40e-6
% Multipath channel specs are below. Only used for multipath channel
max_delayspread = 4.57*T; % maximum delay spread in microsec. 
num_multipath_clusters = 6; % Number of multipath clusters.
max_clusterdelayspread = 0.7*T; % maximum delay spread in microsec within each cluster.

Ns = N*T*fs; % Number of filter samples


% **********************************************************
% Modulation

% Create bits
bits = (randn(2*LL,1))>0;

% Use sqrt-raised cosine filter form  ww=FIRRCOS(N,Fc,R,Fs,'rolloff',TYPE) as p^b(t)
p = firrcos(Ns,1/2/T,alpha,fs,'rolloff','sqrt'); p = p/norm(p)/sqrt(1/fs); % '1/fs' simply serves as 'delta' to approximate integral as sum
% Use rectangular pulse as one possible filter ???

% Create baseband signals (uses 4-QAM modulation)
bitsI = bits(1:2:end);
bitsQ = bits(2:2:end);
xIk = 2*bitsI-1;
xQk = 2*bitsQ-1;
xIk_up = upsample(xIk,fs);
xQk_up = upsample(xQk,fs);
xI = conv(xIk_up,p);
xQ = conv(xQk_up,p);
len = min([length(xI) length(xQ)]);
xI = xI(1:len); xQ = xQ(1:len); 


% Quadrature mix the baseband signals to produce RF signal
xpassI = sqrt(2)*xI.*cos(2*pi*fc*[0:len-1]'/fs+phaseoffset);
xpassQ = sqrt(2)*xQ.*sin(2*pi*fc*[0:len-1]'/fs+phaseoffset);

% Add the quadrature signals to get RF output
xt = xpassI + xpassQ;




% **********************************************************
% Channel


% Physical channel
yt = xt + sigma_n*randn(len,1); 
leny = length(yt);



% **********************************************************
% Demodulation

% Matched filter
w = flipud(p);

% A rectangular (ideal) RF filter of bandwidth 3/T (typically RF filter is quite broadband)
whalflen = 20*fs*T;
wsmoothhalflen = ceil(whalflen/100);
wRFBW = 5/T;
wRFbaseequivalent = conv(wRFBW*sinc([-whalflen+wsmoothhalflen+1:whalflen-wsmoothhalflen]'/fs*wRFBW), 1/(2*wsmoothhalflen+1)*ones(2*wsmoothhalflen+1,1));
wRF = wRFbaseequivalent .* (2*cos(2*pi*fc*[-whalflen:whalflen-1]'/fs)); 
wRF = wRF; 

% Filter the received signal y(t) using the RF filter wRF
ytildet = conv(wRF,yt)*(1/fs); % '1/fs' simply serves as 'delta' to approximate integral as sum 


% Quadrature mix ytildet
len2 = length(ytildet);
mI = sqrt(2)*ytildet.*cos(2*pi*fc*(1+frequencyoffsetfraction)*[-whalflen:len2-whalflen-1]'/fs);
mQ = sqrt(2)*ytildet.*sin(2*pi*fc*(1+frequencyoffsetfraction)*[-whalflen:len2-whalflen-1]'/fs);

% Filter mixed signals with low pass filter in each arm
wLPF = wRFbaseequivalent;
yI = conv(wLPF,mI)*(1/fs); % '1/fs' simply serves as 'delta' to approximate integral as sum
yQ = conv(wLPF,mQ)*(1/fs); % '1/fs' simply serves as 'delta' to approximate integral as sum 

% Filter low pass signals with matched filter in each arm
zI = conv(w,yI)*(1/fs); % '1/fs' simply serves as 'delta' to approximate integral as sum
zQ = conv(w,yQ)*(1/fs); % '1/fs' simply serves as 'delta' to approximate integral as sum 


% Sample filtered signal
zIk = zI(Ns+whalflen+whalflen+1:fs*T:end); zIk = zIk(1:LL);
zQk = zQ(Ns+whalflen+whalflen+1:fs*T:end); zQk = zQk(1:LL);

% **********************************************************
% Waveforms and spectra

% Plot scatter diagram
constellationmarkersize = 6;
modsymbols = [1+j, -1+j, -1-j, 1-j];
Ex = 2;
figure()
%LargeFigure(gcf, 0.15); % Make figure large
clf
zoom off
plot(modsymbols,'rs','MarkerSize',constellationmarkersize,'MarkerFaceColor','r')
set(gca,'DataAspectRatio',[1 1 1]) % sets current figure
grid on
hold on
D = max(sqrt(Ex)*1.5, sigma_n*1.5);
axis([-D D -D D])
plot([-D:D/100:D],zeros(size([-D:D/100:D])),'k','LineWidth',2)
plot(zeros(size([-D:D/100:D])),[-D:D/100:D],'k','LineWidth',2)
xlabel('$x^I$, $z^I$')
ylabel('$x^Q$, $z^Q$')


title('Signal space scatter plot')
plot(modsymbols,'rs','MarkerSize',constellationmarkersize,'MarkerFaceColor','r')
for (ii=1:LL)
    plot(zIk(ii)+j*zQk(ii),'bx')
    plot(modsymbols,'rs','MarkerSize',constellationmarkersize,'MarkerFaceColor','r')
end