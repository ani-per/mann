%% Training a MatNet using simulated data of first-order system with a local protocol

tic
close all; clear colors L_list sims;
set(0, 'DefaultFigureVisible', 'off');
set(0, 'DefaultFigureColor', [1 1 1]);
set(0, 'DefaultAxesGridAlpha', 0.35)
fig_size = [50 50 600 300]; fig_count = 1; p_count = 1; font_size = 17.5;

sim_file = '/Users/ap/Documents/AP/APCOLLEGE/Academics/Graduate_School/Research/MultiAgent_NeuralNets/data/local_consensus/4_nodes/sims/sims_4_nodes_760_sims.mat';
load(sim_file);
[X_sims, L_target] = extract_data(sims);
assert(size(X_sims, 3) == size(L_target, 3));
dataset_length = size(X_sims, 3);
seq = randperm(dataset_length);
X_sims = X_sims(:, :, seq);
L_target = L_target(:, :, seq);

num_epochs = 10; % Maximum number of iterations for training
lr = 0.50; % Learning rate
tolerance = 0.5; % Error tolerance

% Structure of hidden arrays
layers.num_neurons = [1; 20; 10; 1];
layers.dimensions.U = [size(L_target, 1), size(X_sims, 1); size(L_target, 1), size(L_target, 1); size(L_target, 1), size(L_target, 1)];
layers.dimensions.V = [size(L_target, 2), size(X_sims, 2); size(L_target, 2), size(L_target, 2); size(L_target, 2), size(L_target, 2)];
layers.dimensions.B = [size(L_target, 1), size(X_sims, 2); size(L_target, 1), size(L_target, 2); size(L_target, 2), size(L_target, 2)];

% Range of each weight array after initialization
rand_dim = [-1, 1];

% Create MatNet
my_matnet = MatNet(layers, rand_dim);
my_matnet.train_batch(X_sims, L_target, lr, num_epochs, tolerance);

toc