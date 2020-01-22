%% Generation of training data through simulation of first-order system using a local protocol

tic
close all; clear colors L_list sims;
set(0, 'DefaultFigureVisible', 'off');
set(0, 'DefaultFigureColor', [1 1 1]);
set(0, 'DefaultAxesGridAlpha', 0.35);
fig_size = [50 50 600 300]; fig_count = 1; p_count = 1; font_size = 17.5;

% Parameters of simulation
num_runs = 30; % Counter of number of simulations for each L matrix
depict = false; % Plot the results for each individual simulation
save_ind = false; % Save the results for each individual simulation in csv files
timestep = 0.125; % Timestep for ODE 45 integration

for n = 2:5 % Number of nodes, lower limit 2 and upper limit 5 (for now),
            % as 6+ have many more unique Laplacians and hence require much
            % more memory/time to run
    disp('n: ' + n); % Track progress in L
    sim_count = 1; % Counter of number of individual simulations
    L_count = 1; % Counter of number of unique L matrices generated

    % Misc variables
    colors = distinguishable_colors(n);

    % Generate all possible Laplacians for n nodes
    L_list = generate_L_undirected(n);
    sim_count_total = size(L_list, 3)*num_runs; % Total number of individual simulations
    sims = repmat(struct('L', [], 'L_hash', [], 'X', []), 1, sim_count_total);

    for i = 1:size(L_list, 3)
        % Hash generation for L
        L = L_list(:, :, i);
        L_hash = GetMD5(L);
        disp('L Hash: ' + L_hash); % Track progress in L

        % Domain
        t_range = [0:timestep:10];
        xbounds = [0, 10];

        for j = 1:num_runs
            sims(sim_count).L = L;
            sims(sim_count).L_hash = L_hash;

            % Track progress in individual simulations
            disp('Sim ' + sim_count + '/' + sim_count_total);

            % Simulate
            [T, X] = simulate(@local_protocol, L, t_range, L_hash, depict, xbounds, j, colors, fig_size, font_size);
            sims(sim_count).X = X;
            sim_count = inc(sim_count);
            
            if (save_ind)
                root = fullfile(pwd, 'data', 'local_consensus', n + '_nodes', 'ind');
                smart_mkdir(root);
                writematrix(X, fullfile(root, 'sims_' + n + '_nodes_' + 'L_' + L_hash + '_' + int2str(j) + '.csv'))
            end
        end
        L_count = inc(L_count);
    end
    sim_count = sim_count - 1;

    % Save total results of simulations
    root = fullfile(pwd, 'data', 'local_consensus', n + '_nodes', 'sims');
    smart_mkdir(root);
    save(fullfile(root, 'sims_' + n + '_nodes_' + sim_count + '_sims' + '.mat'), 'sims')
    
    % Save hashes and corresponding Laplacians for hashing in R
    L_keys = vertcat(sims(:).L_hash);
    L_vals = cat(3, sims(:).L);
    root = fullfile(pwd, 'hash', 'keys_vals', 'local_consensus', n + '_nodes');
    smart_mkdir(root);
    save(fullfile(root, 'hash_' + n + '_nodes_' + sim_count + '_sims' + '.mat'), 'L_keys', 'L_vals')
    
    % Construct vectorized feature and target matrices from simulations
    all_x = cat(3, sims(:).X);
    feature = permute(reshape(all_x, 1, size(all_x, 1)*size(all_x, 2), size(all_x, 3)), [3 2 1]);
    feature = feature./max(feature, [], 2);
    target = permute(reshape(L_vals, 1, size(L_vals, 1)*size(L_vals, 2), size(L_vals, 3)), [3 2 1]);
    target = target./max(target, [], 2);
    
    % Save feature and target matrices of simulations
    root = fullfile(pwd, 'data', 'local_consensus', n + '_nodes', 'feature');
    smart_mkdir(root);
    save(fullfile(root, 'feature_' + n + '_nodes_' + sim_count + '_sims' + '.mat'), 'feature');
    root = fullfile(pwd, 'data', 'local_consensus', n + '_nodes', 'target');
    smart_mkdir(root);
    save(fullfile(root, 'target_' + n + '_nodes_' + sim_count + '_sims' + '.mat'), 'target');
    
    % Import into R? https://stackoverflow.com/q/28080579
    % Hashing in Matlab: https://stackoverflow.com/a/3592050
    % Hashing in R: hashmap, https://stackoverflow.com/a/46069560
end

toc