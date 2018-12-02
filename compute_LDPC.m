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
coded_bits = LDPC_code.encode_bits(message_bits);

%flip some bits, add some noise
flipping_bits = rand(block_len, 1) < 0.5;
flipped_code = mod((coded_bits + flipping_bits), 2);

%modulate, here with BPSK, to then decode
modulated_bits = zeros(size(flipped_code));
for jj = 1:size(flipped_code)
    if flipped_code(jj) > 0
        modulated_bits(jj) = 1;
    else
        modulated_bits(jj) = -1;
    end
end

sigma = 0.4;
AWG_noise = sigma/sqrt(2)*(randn(block_len, 1)); 

received_bits = modulated_bits + AWG_noise;

No = 0.5; %debugging number, update later with actual calculation

llr = LDPC_code.find_llr(received_bits, No);
llr = llr .* (1 - 2*flipping_bits);



        

