% Transmitter 

clear()
clc 

% **********************************************************
% Load the parameters 
% TODO: to be loaded from the parameter file

freq_pre_lgh = 100; 
time_pre_lgh = 100;
pilote_lgh = 40;
fram_pre_lgh = 100;
transmit_file_name = 'shannon88.bmp'; 
chunk_length = 100; 
M = 4;  
d = 2;
b = log2(M);
alpha = 0;             
N = 11;                
fs = 100;               
T = 1 ;

% **********************************************************
% Prepare the bit signal 

% Get bits data from file TODO: change with get_bits_from_file(transmit_file_name); 
message = randn(300,1)>0;
message_lgh = length(message);

% Prepare preambules
freq_pre = ones(freq_pre_lgh,1);    % Frequency sync preambule 
time_pre = randn(time_pre_lgh,1)>0; % Time sync preambule 
fram_pre = randn(fram_pre_lgh,1)>0; % Frame sync preambule 
pilote   = ones(pilote_lgh,1);      % pilote 

% Construct the final bit sequence (only for debuging)
lm = length(message);
x = [freq_pre; time_pre; pilote; fram_pre]; % x is the final sequence

chunks = mat2tiles(message,[chunk_length, 1]); % The message chunked 
x = [x; chunks{1}];

for i = 2: floor(lm/chunk_length)
    x = [x; pilote; chunks{i}]; % Insert pilote every chunk_length 
end


% **********************************************************
% Modulation

% Compute the symbol energy parameter given M and d 

% Symbol energy M-QAM
if rem(b,2)==0 % Square
    ExQAM = d^2/6*(M-1);
elseif rem(b,2)==1 && b>3 % Cross
    ExQAM = d^2/6*(31/32*M-1);
else % 8-QAM is special
    ExQAM = d^2*3/2;
end

% Symbol energy M-PSK
ExPSK = d^2/(4*(sin(pi/M))^2);

% Compute the modulation preambules using a M-PSK 
mod_freq_pre = modulation(freq_pre, false, M, ExPSK, d); 
mod_time_pre = modulation(time_pre, false, M, ExPSK, d); 
mod_fram_pre = modulation(fram_pre, false, M, ExPSK, d); 	
mod_pilote   = modulation(pilote  , false, M, ExPSK, d); 	

% Compute the modulation message using a M-QAM 
mod_message  = modulation(message , true , M, ExQAM, d); 

% Build xk
lmm = length(mod_message);
xk = [mod_freq_pre; mod_time_pre; mod_pilote; mod_fram_pre];

chunks = mat2tiles(mod_message,[chunk_length, 1]); % The message chunked 
xk = [xk; chunks{1}];

for i = 2: floor(lmm/chunk_length)
    xk = [xk; mod_pilote; chunks{i}]; % Insert pilote every chunk_length 
end 

% Convolution with the pulse (match filtering)
xt = conv(xk, get_pulse(alpha, N, fs));


% **********************************************************
% Plot 

% Plot time domain signals
figure(1)
LargeFigure(gcf, 0.15); % Make figure large
clf

% Plot p(t)
p = get_pulse(alpha, N, fs);
lenp = length(p);
subplot(2,1,1);
display_continuous_signal([-floor(lenp/2): lenp-floor(lenp/2)-1]/fs*T, p, 'time', 'p(t)', 'pulse (frequency domain)')

% Plot x(t)
lenx = length(xt);
subplot(2,1,2);
display_continuous_signal([1:lenx]/fs*T, xt, 'time', 'x(t)', 'baseband signal (time domain)')
zoom xon


% Plot x 
figure(2)
clf
display_continuous_signal(1:length(x), x, 'bit', 'bit value', 'tramsitted sequence in bits')
zoom on 

% Plot frequency domain signals
figure(3)
LargeFigure(gcf, 0.15); % Make figure large
clf

% Plot |P(f)|
subplot(2,1,1)
display_continuous_signal([-lenp/2+1:lenp/2]/lenp*fs/T,20*log10(abs(fftshift(1/sqrt(lenp)*fft(p,lenp)))), 'frequency', '|P(f)| in dB', 'Pulse (frequency domain)');

% Plot |X(f)|
subplot(2,1,2)
display_continuous_signal([-lenx/2+1:lenx/2]/lenx*fs/T,20*log10(abs(fftshift(1/sqrt(lenx)*fft(xt,lenx)))), 'frequency', '|X(f)| in dB', 'baseband signal (frequency domain)');
zoom xon

% Signal space 
figure(4)
LargeFigure(gcf, 0.15); % Make figure large
clf

% Plot the M-PSK constellation
subplot(1,2,1)
plot(real(mod_message),imag(mod_message),'rs','MarkerFaceColor','r','Markersize',14) 
axis([-2*sqrt(ExPSK) 2*sqrt(ExPSK) -2*sqrt(ExPSK) 2*sqrt(ExPSK)])
xlabel('I')
ylabel('Q')

% Plot the M-QAM constellation
subplot(1,2,2)
plot(real(mod_time_pre),imag(mod_time_pre),'rs','MarkerFaceColor','r','Markersize',14) 
axis([-2*sqrt(ExQAM) 2*sqrt(ExQAM) -2*sqrt(ExQAM) 2*sqrt(ExQAM)])
xlabel('I')
ylabel('Q')



