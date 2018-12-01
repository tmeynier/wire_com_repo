classdef LDPC_class < handle

    
    properties
        parity_matrix;
        codeword_len;
        info_len;
        parity_len;        
        syndrome_len;
    end
    
    methods
        function obj = LDPC_class(block_length, info_length)
            obj.codeword_len = block_length;
            obj.info_len = info_length;
            obj.parity_len = block_length - info_length;
        end
        
        
        function [codeword] = encode_bits(obj, info_bits)
                info_size = obj.info_len;
                syndrome_size = obj.syndrome_len;
                codeword_size = obj.codeword_len;
                % Generate codeword first by adding info bits, parity check
                % bits after
                % http://sigpromu.org/sarah/SJohnsonLDPCintro.pdf
                p_matrix = obj.parity_matrix;
                codeword = zeros(obj.codeword_len, 1);
                codeword(1:info_size) = info_bits;
                
                bit_parity = p_matrix * codeword;
                              
                spacing = obj.syndrome_len;
                
                for ii = 1:spacing
                    curr_parity = mod(sum(bit_parity(ii:spacing:end)), 2);
                    codeword(info_size + ii) = curr_parity;
                end

                parity_with_syndrome = p_matrix(:, info_size+1 : info_size+syndrome_size);
                codeword_with_rate = codeword(info_size+1: info_size + syndrome_size);
                bit_parity = mod(bit_parity + parity_with_syndrome * codeword_with_rate(:), 2);
                
                for iter = info_size + syndrome_size + 1 : syndrome_size : codeword_size
                    codeword(iter : iter + syndrome_size - 1) = bit_parity (iter - info_size - syndrome_size : iter - info_size - 1);
                    bit_parity(iter - info_size : iter - info_size + syndrome_size - 1)...
                        = mod(bit_parity(iter - info_size - syndrome_size:iter - info_size - 1) +...
                        bit_parity(iter - info_size : iter - info_size + syndrome_size - 1), 2);
                        
                end

                       
        end
                
        
        function load_parity_matrix(obj, block_length)
            
                load 'half_rate_1944.mat';
                
                obj.syndrome_len = 81;
                obj.parity_matrix = p_matrix;
                obj.codeword_len = 1944;
                obj.parity_len = 1944 / 2;
                obj.info_len = 1944 / 2;
            
        end
        
    end
    
end

