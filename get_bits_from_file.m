% Tool function, takes a file name as parameter and return the bit sequence
% encoding of this file as a row vector
% EXAMPLE USE: get_bits_from_file('shannon88.bmp')

function y = get_bits_from_file(transmit_file_name)
    
image = imread(transmit_file_name);
y = reshape(image, [], 1);

end 