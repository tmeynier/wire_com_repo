classdef LDPC_class < handle
    
    
    properties
        parity_matrix;
        codeword_len;
        info_len;
        parity_len;
        syndrome_len;
    end
    
    methods
        function obj = LDPC_class(block_len, info_length)
            obj.codeword_len = block_len;
            obj.info_len = info_length;
            obj.parity_len = block_len - info_length;
        end
        
        
        function [codeword] = encode_bits(obj, message_bits)
            info_size = obj.info_len;
            syndrome_size = obj.syndrome_len;
            codeword_size = obj.codeword_len;
            % Generate codeword first by adding info bits, parity check
            % bits after
            % http://sigpromu.org/sarah/SJohnsonLDPCintro.pdf
            p_matrix = obj.parity_matrix;
            codeword = zeros(obj.codeword_len, 1);
            codeword(1:info_size) = message_bits;
            
            bit_parity = p_matrix * codeword;
            
            spacing = obj.syndrome_len;
            
            for ii = 1:spacing
                curr_parity = mod(sum(bit_parity(ii:spacing:end)), 2);
                codeword(info_size + ii) = curr_parity;
            end
            
            % equation at bottom of Modern Coding Theory by Richardson
            % and Urbanke, page 437
            % pl = - sum from j = l+1 to n-k of H_(l,j)pj - sum from
            % j=1 to k of H_(l,(j+n-k))s_j
            
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
        
        
        function load_parity_matrix(obj, block_len)
            
            load 'half_rate_1944.mat';
            
            % depending on total block length
            obj.syndrome_len = 81;
            obj.parity_matrix = p_matrix;
            obj.codeword_len = 1944;
            obj.parity_len = 1944 / 2;
            obj.info_len = 1944 / 2;
            
        end
        
        function llr_vector = find_llr(obj, received_signal, No)
            % Based on llr calculation on p. 498 of "Contemporary Comm
            % Systems using Matlab" by Proakis, Salehi, Bauch, assuming
            % BPSK maps 1 to -1 and 0 to +1 - contrary to some previous
            % definitions
            prob_y_0 = zeros(length(received_signal), 1);
            prob_y_1 = zeros(length(received_signal), 1);
            
            for iter = 1:length(received_signal)
                % calculate probability of result being a 0
                prob_0 = exp(-abs(received_signal(iter) - 1)^2/No);
                prob_y_0((iter-1) + 1) = prob_y_0((iter-1) + 1) + prob_0;
                
                % calculate probability of result being a 1
                prob_1 = exp(-abs(received_signal(iter) + 1)^2/No);
                prob_y_1((iter-1) + 1) = prob_y_1((iter-1) + 1) + prob_1;
            end
            llr_vector = log(prob_y_0./prob_y_1);
        end
        
        
        function [decoded_message, bit_errors] = decode_bits(obj, llr_vector, total_runs)
            
            curr_llr_vector = llr_vector;
            bit_errors = 0;
            max_bound = 25;
            
            p_matrix = sparse(obj.parity_matrix);
            last_iteration = p_matrix * 0;
            rows = length(p_matrix(:, 1));
            cols = length(p_matrix(1, :));
            decoded_message = zeros(cols);
            
            %belief propogation, trade between check and variable nodes
            for curr_run = 1 : total_runs
                curr_llr_matrix = spdiags(curr_llr_vector, 0, cols, cols);
                curr_belief = p_matrix * curr_llr_matrix - last_iteration;
                
                % enforce strong bound on values elements can take
                curr_belief = min(curr_belief, max_bound);
                curr_belief = max(curr_belief, -max_bound);
                
                % compute message from check node to variable node
                curr_message = tanh(curr_belief * 0.5);
                p_matrix_rows = length(p_matrix(:, 1));
                check_product = zeros(p_matrix_rows);
                
                for curr_var_node = 1:p_matrix_rows
                    elements = find(curr_message(curr_var_node, :));
                    check_product(curr_var_node, 1) = prod(tanh(0.5*curr_belief(curr_var_node, elements(:))), 2);
                end
                check_product = full(real(check_product));
                
                % want to find element-by-element inverse of the inner
                % argument - hyperbolic tan(~)
                % first way was very slow - did not take advantage of
                % sparse matrix operations and thus shoud be avoided
                % rather, can compute with a mathematical identity of
                % e^(-ln(x)) equaling 1/x
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % check = check.^-1;                                     %
                % check = real(check);                                   %
                % result = spdiags(check_product, 0, rows, rows) * check;%
                % very slow, don't use                                   %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                
                % compute message from variable node to check node based on
                % received info from check nodes
                % knowing that d/dx ln(x) = 1/x, calculate with following
                 
                %check = tanh(0.5 * curr_belief);
                %log_check = spfun('log', curr_message);

                log_check = spfun('log', curr_message);

                elem_elem_inverse = real(spfun('exp', -log_check));
                
                variable_prod = spdiags(check_product, 0, rows, rows);
                variable_prod = variable_prod * elem_elem_inverse;
                
                update_llr = 2*atanh(variable_prod);
                last_iteration = update_llr;
                curr_llr_vector = llr_vector + sum(update_llr).';
                
                % check if decoded
                %decoded_message = (curr_llr_vector < 0);
                
            end
            decoded_message = (curr_llr_vector > 0);
        end
        
    end
    
end

