%% Generation of training data through simulation of first-order system using a local protocol

tic
close all;
set(0, 'DefaultFigureVisible', 'off');
set(0, 'DefaultFigureColor', [1 1 1]);
set(0, 'DefaultAxesGridAlpha', 0.35)
fig_size = [50 50 600 300]; fig_count = 1; p_count = 1; font_size = 17.5;

n = 6; % Number of nodes
sim_count = 1; % Counter of number of individual simulations
L_count = 1; % Counter of number of unique L matrices generated
num_runs = 4; % Counter of number of simulations for each L matrix

% Misc variables
colors = distinguishable_colors(n);
member_names = cell(1, n);
for i = 1:n
    member_names{1, i} = strcat("Node ", int2str(i));
end


% Graph topology
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

% Laplacian
L = D - A; % Generate L
systems(sim_count).L = L;

% Hash generation for L
L_hash = GetMD5(L);
systems(sim_count).L_hash = L_hash;

% Simulation
depict = true;
t_range = [0, 10];
xbounds = [0, 10];

for i = 1:num_runs
    [T, X] = simulate(@local_protocol, L, t_range, L_hash, xbounds, depict, i, colors, fig_size, font_size);
    systems(sim_count).X = X;
    inc(sim_count);
end
inc(L_count);

toc