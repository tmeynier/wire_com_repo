% tool function to display a continuous time signal

function display_compare_discrete_signal(x_signal, y1_signal, y2_signal, x_label, y1_label, y2_label, title)

clf

stem(x_signal,y1_signal,'b')
hold on
stem(x_signal,y2_signal,'r')
ylabel(strcat(y1_label, ', ', y2_label))
xlabel(x_label)
title(title)
linkaxes(ax,'x')
zoom xon