% This file stores all the parameters of the communication system

clear
close all
clc

alpha = 0; % alpha of sqrt raised cosine filter
N = 11;    % length of filter in symbol periods. Default is 11
fs = 100;  % Over-sampling factor (Sampling frequency/symbol rate). Default is 100
M = 4;     % Number of constellation point for the QAM modulation system