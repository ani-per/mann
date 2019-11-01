%% Generation of training data through simulation of first-order system using a local protocol

tic
close all;
set(0, 'DefaultFigureVisible', 'off');
set(0, 'DefaultFigureColor', [1 1 1]);
set(0, 'DefaultAxesGridAlpha', 0.35)
fig_size = [50 50 750 350]; fig_count = 1; p_count = 1; font_size = 17.5;

% Graph topology
n = 6;
colors = distinguishable_colors(n);
A = zeros(n, n);
D = zeros(n, n);

% Manual entry of graph topology for now
A = [...
    0, 1, 1, 0, 0, 0; ...
    1, 0, 1, 1, 0, 0; ...
    1, 1, 0, 0, 1, 0; ...
    0, 1, 0, 0, 0, 1; ...
    0, 0, 1, 0, 0, 1; ...
    0, 0, 0, 1, 1, 0; ...
    ];
D = [...
    2, 0, 0, 0, 0, 0; ...
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

% Hash generation for L
L_hash = GetMD5(L);

% Simulation
depict = true;
t_range = [0, 5];
xbounds = [0, 10];
member_names = cell(1, n);
for i = 1:n
    member_names{1, i} = strcat("Node ", int2str(i));
end
simulate(@local_protocol, L, t_range, L_hash, depict, member_names, colors, fig_size, font_size);

toc