% Basic code to generate parity matrix based on Gallager's paper
% https://web.stanford.edu/class/ee388/papers/ldpc.pdf
% Define an (n, j, k) parity-check matrix as a matrix of n columns
% that has j ones in each column, k ones in each row, and zeros elsewhere.
% It follows from this definition that an (n, j, k) parity-check matrix has
% nj/k rows and thus a rate R >= 1 - j/k.
% This matrix is divided in to j submatrices, each containing a single 1 in
% each column. The first of these submatrices contains all its 1's in
% descending order; that is, the ith row contains 1's in columns 
% (i - 1)k + 1 to ik. The other submatrices are simply permutations of the
% first

clear all
close all
clc

%n = 10000;                  % number of columns
n = 100;
j = 4;                      % number of ones per column
k = 10;                     % number of ones per row
m = (n*j)/k;                % number of rows

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


% Generate permutations of first submatrix

parity_matrix = first_matrix;
for next_matrices = 2:j
    rand_permutation = randperm(n); % gives locations for new columns
    curr_permutation = first_matrix(:,rand_permutation);
    parity_matrix = [parity_matrix ; curr_permutation];
end

    