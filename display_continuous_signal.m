% tool function to display a continuous time signal

function display_continuous_signal(x_signal, y_signal, x_label, y_label, t)
    
    plot(x_signal, y_signal)
    title(t)
    xlabel(x_label)
    ylabel(y_label) 
    
end