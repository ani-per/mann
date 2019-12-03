% function train_matnet(X_sims, L_target, layers, learning_rate, num_epochs)

% k : layer number
% j : neuron number
% i : local weight number
num_hidden = length(layers.num_neurons) - 1;

% Array for storing loss at each epoch
error = zeros(1, num_epochs);
% Array for storing predicted L for each batch
L_hat = zeros(size(L_target));

for (n = 1:1)
    if (n == 1) % Setup network structure if we're using the first training batch
        % Initialize connection weights
        U = cell(1, num_hidden);
        V = cell(1, num_hidden);
        B = cell(1, num_hidden);

        % Initialize neuron outputs
        N = cell(1, num_hidden + 1);
        H = cell(1, num_hidden + 1);

        % Set up empty hidden layer structure
        for (k = 1:num_hidden)
            U{k} = cell([layers.dimensions.U(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
            V{k} = cell([layers.dimensions.V(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
            B{k} = cell([layers.dimensions.B(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
            N{k + 1} = cell([layers.dimensions.B(k, :), layers.num_neurons(k + 1)]);
            H{k + 1} = cell([layers.dimensions.B(k, :), layers.num_neurons(k + 1)]);
            for (j = 1:layers.num_neurons(k + 1))
                for (i = 1:layers.num_neurons(k))
                    U{1, k}(:, :, i, j) = num2cell(randn(layers.dimensions.U(k, :)));
                    V{1, k}(:, :, i, j) = num2cell(randn(layers.dimensions.V(k, :)));
                    B{1, k}(:, :, i, j) = num2cell(randn(layers.dimensions.B(k, :)));
                end
            end
        end
    end

    % Initialize zeroeth layer neuron outputs to be training input
    H{1, 1} = num2cell(X_sims(:, :, n));
    
    % Forward pass through hidden layers
    for (k = 1:num_hidden)
        for (j = 1:layers.num_neurons(k + 1))
            N{1, k + 1}(:, :, j) = m2c(sum((mtimesx(mtimesx(c2m(U{1, k}(:, :, :, j)), c2m(H{1, k}(:, :, :))), t3(c2m(V{1, k}(:, :, :, j)))) ...
                + c2m(B{1, k}(:, :, :, j))), 3));
            H{1, k + 1}(:, :, j) = m2c(sigmoid(c2m(N{1, k + 1}(:, :, j))));
        end
    end
    L_hat(:, :, n) = c2m(N{1, num_hidden + 1});
    % Calculate error of prediction
    error(n) = se_frob(L_hat(:, :, n), L_target(:, :, n));
end
    
% end