clear
clc

% H is non-systematic, i.e., the last (N-K) columns are not invertible in GF(2)
% Columns [1 4 6 7 9 10] correspond to the information bits
H = [1 1 0 1 0 0 1 0 1 1
     1 1 1 1 0 0 0 0 0 0
     0 0 1 1 1 1 1 0 0 1
     0 1 0 0 1 0 1 1 1 0];

infobits_loc = [1 4 6 7 9 10];

% Permute H to obtain a systematic code
% This is always possible if H has full rank and if infobits_loc is
% correctly defined
paritybits_loc = setdiff(1:size(H,2),infobits_loc);
H2 = H(:,[infobits_loc paritybits_loc]);

% Create LDPC encoder
encoder = comm.LDPCEncoder(sparse(H2));

modulation = comm.PSKModulator(4, 'BitInput',true);

channel = comm.AWGNChannel(...
          'NoiseMethod','Signal to noise ratio (SNR)','SNR',1);
      
demodulation = comm.PSKDemodulator(4, 'BitOutput',true,...
               'DecisionMethod','Approximate log-likelihood ratio', ...
               'Variance', 1/10^(channel.SNR/10));
      
decoder = comm.LDPCDecoder(sparse(H2));

error = comm.ErrorRate;

for counter = 1:5000
% Generate random information bits
infobits = rand(size(infobits_loc'))>0.5;

% Generate an intermediate codeword using LDPC encoder object
codeword = step(encoder,infobits);

% Modulate signal
modulatedSignal = step(modulation, codeword);

% Transmit over AWGN channel
receivedSignal = step(channel, modulatedSignal);

% Demodulate signal
demodulatedSignal = step(demodulation, receivedSignal);

% Decode signal

decodedSignal = step(decoder, demodulatedSignal);

errorSignal = step(error, infobits, decodedSignal);

end

fprintf('Error rate       = %1.2f\nNumber of errors = %d\n', ...
         errorSignal(1), errorSignal(2))
