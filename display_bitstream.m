% display a stream of bits 

function display_bitstream(x_signal, x_label, y_label, t)
    
    stem([1:length(x_signal)], x_signal)    
    title(t)
    xlabel(x_label)
    ylabel(y_label) 
    
end
