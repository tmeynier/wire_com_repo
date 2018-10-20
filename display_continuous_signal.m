% tool function to display a continuous time signal

function display_continuous_signal(x_signal, y_signal, x_label, y_label, title)

    clf
    plot(x_signal, y_signal)
    xlabel(x_label)
    ylabel(y_label)
    title(title)