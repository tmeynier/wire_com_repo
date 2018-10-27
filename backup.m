% Build the bit sequence to send 
lm = length(message);
x = [freq_pre; time_pre; pilote; fram_pre]; % x is the final sequence

chunks = mat2tiles(message,[chunk_length, 1]); % The message chunked 
x = [x; chunks{1}];

for i = 2: floor(lm/chunk_length)
    x = [x; pilote; chunks{i}]; % Insert pilote every chunk_length 
end




preambules_length = freq_pre_lgh + time_pre_lgh + pilote_lgh + fram_pre_lgh;
xk = modulation(x(1:preambules_length), false, M, ExPSK, d); 



xk = [xk; modulation(x(preambules_length + 1 : preambules_length + min(chunk_length, message_lgh)),true, M, ExQAM, d)];

for i = 2: floor(lm/chunk_length)
    start_indexi1 = preambules_length + chunk_length + (i-2)*(chunk_length + pilote_lgh);
    xk = [xk; modulation(x(start_indexi1 + 1: start_indexi1 + pilote_lgh),false, M, ExPSK, d)];
    
    start_indexi2 = start_indexi1 + pilote_lgh;
    xk = [xk; modulation(x(start_indexi2 + 1 : start_indexi2 + chunk_length),true, M, ExQAM, d)];
end 