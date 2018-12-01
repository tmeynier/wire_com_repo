clc;
clear all;


% create initial object
LDPC_code = LDPC_class(0, 0);

block_len = 1944;
rate = 1/2;

LDPC_code.load_parity_matrix(block_len);
info_len = LDPC_code.info_len;

message_bits = rand(info_len, 1) < 0.5;
%Encode bits
coded_bits = LDPC_code.encode_bits(message_bits)

%flip some bits, add some noise
flipping_bits = rand(block_len, 1) < 0.5;
flipped_code = mod((coded_bits + flipping_bits), 2);

sigma = 0.4;
AWG_noise = sigma/sqrt(2)*(randn(block_len, 1)); 

received_bits = flipped_code + AWG_noise;


