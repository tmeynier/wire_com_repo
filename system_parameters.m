% This file stores all the parameters of the communication system

clear

% **********************************************************
% Pulse parameters 

alpha = 0;              % alpha of sqrt raised cosine filter
N = 11;                 % length of filter in symbol periods. Default is 11
fs = 100;               % Over-sampling factor (Sampling frequency/symbol rate). Default is 100

% **********************************************************
% Constellation parameters (M-QAM)

M = 4;                  % Number of constellation point for the QAM modulation system
d = 2;                  % Minimum distance

% Compute the parameter Ex (symbol energy) given d and M 
if rem(b,2)==0 % Square
    Ex = d^2/6*(M-1);
elseif rem(b,2)==1 && b>3 % Cross
    Ex = d^2/6*(31/32*M-1);
else % 8-QAM is special
    Ex = d^2*3/2;
end

% **********************************************************
% Synchronization methods parameters

freq_pre_lgh = 1000;    % Length of the frequency sync preambule 
time_pre_lgh = 1000;    % Length of the timing sync preambule 
fram_pre_lgh = 1000;    % Length of the frame sync preambule 
pilote_lgh   = 1000;      % Length of the pilote. Attention: the lenght of 
                        % the pilote sequence must be at most 20% of the
                        % message chunck length (attention: the length in
                        % symbol periode)
chunk_length = 20000;   % Length of chunk message between each pilote
transmit_file_name = 'shannon88.bmp'; % Name of the file containing the bits to transmit 

