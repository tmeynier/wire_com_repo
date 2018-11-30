classdef LDPC
        properties
           n;               %length of info + parity bits
           j;               %num ones per column (column weight)    
           k;               %num ones per row (row weight)
           m;               %num parity bits
           parity_matrix;               
           max_j;
           max_k;
           col_weights;
           row_weights;
        end
        
        methods
            function obj = form_matrix(block_length, info_length)
                obj.n = block_length;
                obj.k = info_length;
                obj.m = block_length - info_length;
            end
            
            function obj = form_matrix_rate(rate, info_length)
                obj.k = info_length;
                obj.n = info_length / rate;
                obj.m = obj.n - obj.k;
            end
            
            function paritymatrix = generate_parity_matrix(obj)

                %n = 10000;                  % number of columns
%                 n = 100;
%                 j = 4;                      % number of ones per column
%                 k = 10;                     % number of ones per row
%                 m = (n*j)/k;                % number of rows
                n = obj.n;
                j = obj.j;
                k = obj.k;
                m = obj.m;

                first_matrix_zero = zeros(n/k, n);
                %parity_matrix = zeros(m, n);

                % Generate first submatrix, of which all subsequent submatrices are just
                % permutations of this first
                first_matrix = first_matrix_zero;
                for ii = 1:(n/k)            % number of 1's per row
                    for jj = 1 + k*(ii-1):k*ii
                        first_matrix(ii, jj) = 1;
                    end
                 end
            end
        
            function accumulate(obj)
                parity_matrix = obj.parity_matrix;
                obj.col_weights = sum(parity_matrix, 1);
                obj.row_weights = sum(parity_matrix, 2);
                
            end
            
            
            
            function [codeword] = encode_LDPC(obj, info_bits)
                % Generate codeword first by adding info bits, parity check
                % bits after
                %http://sigpromu.org/sarah/SJohnsonLDPCintro.pdf
                codeword = zeros(obj.n, 1);
                codeword(1:obj.k) = info_bits;
                
                parity_bits = zeros(obj.m, 1);
                
            end