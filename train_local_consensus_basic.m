%% Generation of training data through simulation of first-order system using a local protocol

tic
close all; clear colors L_list systems;
set(0, 'DefaultFigureVisible', 'off');
set(0, 'DefaultFigureColor', [1 1 1]);
set(0, 'DefaultAxesGridAlpha', 0.35)
fig_size = [50 50 600 300]; fig_count = 1; p_count = 1; font_size = 17.5;

n = 4; % Number of nodes, upper limit 5 for now
sim_count = 1; % Counter of number of individual simulations
L_count = 1; % Counter of number of unique L matrices generated
num_runs = 4; % Counter of number of simulations for each L matrix
depict = false; % Plot the results for each individual simulation

% Misc variables
colors = distinguishable_colors(n);

% Generate all possible Laplacians for n nodes
L_list = generate_L_undirected(n);
sim_count_total = size(L_list, 3)*num_runs; % Total number of individual simulations
systems = repmat(struct('L', [], 'L_hash', [], 'X', []), 1, sim_count_total);

for i = 1:size(L_list, 3)

    % Hash generation for L
    L = L_list(:, :, i);
    L_hash = GetMD5(L);
    disp("L Hash: " + L_hash); % Track progress in L

    % Domain
    t_range = [0:0.05:10];
    xbounds = [0, 10];
    
    for i = 1:num_runs
        systems(sim_count).L = L;
        systems(sim_count).L_hash = L_hash;
        
        % Track progress in individual simulations
        disp("Sim " + sim_count + "/" + sim_count_total)
        
        % Simulate
        [T, X] = simulate(@local_protocol, L, t_range, L_hash, depict, xbounds, i, colors, fig_size, font_size);
        systems(sim_count).X = X;
        sim_count = inc(sim_count);
    end
    L_count = inc(L_count);
end

toc