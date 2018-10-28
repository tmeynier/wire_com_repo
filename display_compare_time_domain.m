% **********************************************************
% Waveforms and spectra
% xt, yt are time-domain signals

% Plot time domain signals

function display_compare_time_domain(xt, yt, ytildet, mI, yI, zI, xIk, zIk, xQk, zQk)

ax = [];
figure()
clf
ax(1) = subplot(4,2,1);

% x(t)
plot([1:length(xt)]/fs, xt)
ylabel('$x(t)$')

% y(t)
ax(2) = subplot(4,2,3);
plot([1:length(yt)]/fs, yt)
ylabel('$y(t)$')

% filtered y(t) [y_tilde(t)]
ax(3) = subplot(4,2,5);
plot([1:length(ytildet)]/fs, ytildet)
ylabel('$y^{tilde}(t)$')

% quadrature-mixed in-phase arm
ax(4) = subplot(4,2,7);
plot([1:length(mI)]/fs,mI)
ylabel('$m^I(t)$')
xlabel('time $t$ in  microseconds')

% filter mixed signal with low pass filter
ax(5) = subplot(4,2,2);
plot([1:length(yI)]/fs,yI)
ylabel('$y^I(t)$')

% filter low pass signal with matched filter
ax(6) = subplot(4,2,4);
plot([1:length(zI)]/fs,zI)
ylabel('$z^I(t)$')
xlabel('time $t$ in  microseconds')
axis tight

% comparison of transmitted symbols and guesses
ax(7) = subplot(4,2,6);
stem([1:LL],xIk,'b')
hold on
stem([1:LL],zIk,'r')
ylabel('$x^I_k,   z^I_{k}$')
xlabel('discrete time  $k$  (sampled at $t=kT$)')


ax(8) = subplot(4,2,8);
stem([1:LL],xQk,'b')
hold on
stem([1:LL],zQk,'r')
ylabel('$x^Q_k,   z^Q_{k}$')
xlabel('discrete time  $k$  (sampled at $t=kT$)')
linkaxes(ax,'x')
zoom xon