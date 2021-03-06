%% Simulation of consensus for first-order system using a local protocol

tic
close all; clear all;
set(0, 'DefaultFigureVisible', 'off');
set(0, 'DefaultFigureColor', [1 1 1]);
set(0, 'DefaultAxesGridAlpha', 0.35)
figSize = [50 50 1500 1000]; fig_count = 1; p_count = 1; fontsize = 25;

% Graph topology
n = 6;
colors = distinguishable_colors(n);
A = zeros(n, n);
D = zeros(n, n);

% Manual entry of graph topology for now
A = [...
    0, 0, 1, 0, 0, 0; ...
    1, 0, 1, 1, 0, 0; ...
    1, 1, 0, 0, 1, 0; ...
    0, 1, 0, 0, 0, 1; ...
    0, 0, 1, 0, 0, 1; ...
    0, 0, 0, 1, 1, 0; ...
    ];
D = [...
    1, 0, 0, 0, 0, 0; ...
    0, 3, 0, 0, 0, 0; ...
    0, 0, 3, 0, 0, 0; ...
    0, 0, 0, 2, 0, 0; ...
    0, 0, 0, 0, 2, 0; ...
    0, 0, 0, 0, 0, 2; ...
    ];
if (~issymmetric(A))
    warning("A isn't symmetric! This means consensus may not be guaranteed!");
end
if (~issymmetric(D))
    warning("D isn't symmetric! This means consensus may not be guaranteed!");
end
L = D - A;

% Simulation
tbounds = [0, 5];
xbounds = [0, 10];
x0 = randrange(n, xbounds);
member_names = cell(1, n);
for i = 1:n
    member_names{1, i} = strcat("Member ", int2str(i));
end
[T, X] = ode45(@local_protocol, tbounds, x0, [], L);

% Figure generation
tic
fh(fig_count) = figure(fig_count);
for i = 1:n
    hold on;
    plot(T, X(:, i), 'LineWidth', 2.5, 'Color', colors(i, :));
end
fh(fig_count).Position = figSize;
xlabel('Time [t] (s)', 'Interpreter', 'Latex', 'FontSize', fontsize)
ylabel('Position [x] (m)', 'Interpreter', 'Latex', 'FontSize', fontsize)
title('Position [x] vs. Time [t] (s)', 'Interpreter', 'Latex', 'FontSize', fontsize)
legend(member_names, 'Location', 'northeastoutside', 'Interpreter', 'Latex', 'FontSize', fontsize);
grid on;
export_fig('./figs/local_consensus.png')
fig_count = inc(fig_count);
toc

toc