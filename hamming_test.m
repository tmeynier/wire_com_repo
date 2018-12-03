%Implementation of a (7, 4) Hamming Code
clear all
clc

[h, g, n, k] = hammgen(3);
info_bits = rand(n, 1) < 0.5;
code = encode(info_bits, n, k, 'hamming');
% some probability that a bit flips
% transmit_code = code;
% for (ii = 1:size(code))
%     for ii = 1:size(transmit_code)
%         if (transmit_code(ii) == 1)
%             transmit_code(ii) = 0;
%         else
%             transmit_code(ii) = 1;
%         end
%     end
% end
% num_transmit_errors = 0;
% for (jj = 1:size(transmit_code))
%     if (transmit_code(jj) ~= code(jj))
%         num_transmit_errors = num_transmit_errors + 1;
%     end
% end

msg = decode(code, n, k, 'hamming');
% num_receive_errors = 0;
% for (kk = 1:size(msg))
%     if (msg(kk) ~= code(kk))
%         num_receive_errors = num_receive_errors + 1;
%     end
% end
