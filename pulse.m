% pulse used in the communication system

clear
close all
clc

p = rcosdesign(alpha, N, fs, 'sqrt'); 
p = p/norm(p)/sqrt(1/(fs)); 
p = reshape(p,[],1); % '1/fs' simply serves as 'delta' to approximate integral as sum