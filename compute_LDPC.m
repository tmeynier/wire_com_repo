clc;
clear all;


% create initial object
LDPC_code = LDPC_class(0, 0);

block_length = 1944;
rate = 1/2;

LDPC_code.load_parity_matrix(block_length);
info_length = LDPC_code.info_len;

info_bits = rand(info_length, 1) < 0.5;
%Encode bits
coded_bits = LDPC_code.encode_bits(info_bits)
