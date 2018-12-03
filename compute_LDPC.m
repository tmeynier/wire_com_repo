clc;
clear all;


% create initial object
LDPC_code = LDPC_class(0, 0);

%half rate code
block_len = 1944;

LDPC_code.load_parity_matrix(block_len);
info_len = LDPC_code.info_len;

message_bits = rand(info_len, 1) < 0.5;
%Encode bits
coded_bits = LDPC_code.encode_bits(message_bits);

% calculate Eb/No after experimenting with some values
No = 5;
snr_in_db = No + 10*log10(No)


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

AWG_noise = sqrt(No) * randn(1944, 1);



snr_in_db = 10^(snr_in_db/10);
received_bits = modulated_bits + AWG_noise/sqrt(snr_in_db);

llr = LDPC_code.find_llr(received_bits, No);
llr = llr .* (1 - 2*flipping_bits);

[resulting_message, error_bits] = decode_bits(LDPC_code, llr, 20);

num_same_bits = numel(find(resulting_message == coded_bits));

ber = abs((num_same_bits - block_len) / block_len)


        

