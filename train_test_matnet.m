%% Training a MatNet using simulated data of first-order system with a local protocol

%% Front Matter
tic
close all; clear sims;
set(0, 'DefaultFigureVisible', 'off');
set(0, 'DefaultFigureColor', [1 1 1]);
set(0, 'DefaultAxesGridAlpha', 0.65);
fig_size = [50 50 1800 1500]; fig_count = 1; font_size = 30;

%% Train/Test Dataset Setup
% Set number of nodes and number of sims
num_nodes = 4;
num_sims = 1140;
sim_file = ...
    fullfile(pwd, 'data', 'local_consensus', ...
    sprintf('%d_nodes', num_nodes), 'sims', sprintf('sims_%d_nodes_%d_sims.mat', num_nodes, num_sims));
assert(isfile(sim_file));
load(sim_file);

% Extract training dataset from sim file
[X_sims, L_target] = extract_data(sims);
assert(size(X_sims, 3) == size(L_target, 3));
dataset_length = size(X_sims, 3);
% Randomly shuffle the order of the dataset
seq = randperm(dataset_length);
X_sims = X_sims(:, :, seq);
L_target = L_target(:, :, seq);
% Partition main dataset into training and testing datasets
train_frac = 0.75;
[X_sims_train, X_sims_test] = split_sims(X_sims, train_frac);
[L_target_train, L_target_test] = split_sims(L_target, train_frac);

%% MatNet Structure & Creation
% Structure of hidden arrays
hidden_neurons = [10; 10];
layers.num_neurons = [1; hidden_neurons; 1];

layers.dimensions.U = [size(L_target, 1), size(X_sims, 1); repmat([size(L_target, 1), size(L_target, 1)], length(layers.num_neurons) - 1, 1)];
layers.dimensions.V = [size(L_target, 2), size(X_sims, 2); repmat([size(L_target, 2), size(L_target, 2)], length(layers.num_neurons) - 1, 1)];
layers.dimensions.B = [size(L_target, 1), size(X_sims, 2); repmat([size(L_target, 1), size(L_target, 2)], length(layers.num_neurons) - 1, 1)];

% Range of each weight array after initialization
rand_dim = [-1, 1];

% Create MatNet
mn = MatNet(layers, rand_dim);

%% MatNet Training Parameters
num_epochs = 5; % Maximum number of iterations for training
lr = 0.75; % Learning rate
tolerance = 0.5; % Error tolerance
num_bins = 30; % Number of bins for error histograms

%% Training
% Train MatNet
disp('Training ...');
mn.train_batch(X_sims_train, L_target_train, lr, num_epochs, tolerance);

%% Training Results
%  Histogram of the training error
error_vector_train = mn.error_vector('raw');
error_hist_train(error_vector_train, 'raw', num_bins, fig_size, font_size, num_nodes, num_sims);
error_vector_train = mn.error_vector('ripe');
error_hist_train(error_vector_train, 'ripe', num_bins, fig_size, font_size, num_nodes, num_sims);
error_vector_train = mn.error_vector('real');
error_hist_train(error_vector_train, 'real', num_bins, fig_size, font_size, num_nodes, num_sims);

%% Testing
% Test MatNet
[test_L_hat, test_error_raw, test_error_ripe, test_error_real] = mn.test(X_sims_test, L_target_test);

%% Testing Results
% Histogram of the test error
error_hist_test(test_error_raw(test_error_raw >= 0), 'raw', num_bins, [50 50 700 700], font_size/1.5, num_nodes, num_sims);
error_hist_test(test_error_ripe(test_error_ripe >= 0), 'ripe', num_bins, [50 50 700 700], font_size/1.5, num_nodes, num_sims);
error_hist_test(test_error_real(test_error_real >= 0), 'real', num_bins, [50 50 700 700], font_size/1.5, num_nodes, num_sims);

%% End Matter
toc