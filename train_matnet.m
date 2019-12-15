% function train_matnet(X_sims, L_target, layers, lr, num_epochs)
tic;

% k : layer number
% j : neuron number
% i : local weight number
num_hidden = length(layers.num_neurons) - 1;

% Array for storing loss at each epoch
error = zeros(1, num_epochs);
% Array for storing predicted L for each batch
L_hat = zeros(size(L_target));

for (n = 1:dataset_length)
    if (n == 1) % Setup network structure if we're using the first training batch
        % Initialize connection weights
        U = cell(1, num_hidden);
        V = cell(1, num_hidden);
        B = cell(1, num_hidden);
        dU = cell(1, num_hidden);
        dV = cell(1, num_hidden);
        dB = cell(1, num_hidden);
        delta = cell(1, num_hidden);

        % Initialize neuron outputs
        N = cell(1, num_hidden + 1);
        H = cell(1, num_hidden + 1);

        % Set up empty hidden layer structure
        for (k = 1:num_hidden)
            U{k} = cell([layers.dimensions.U(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
            V{k} = cell([layers.dimensions.V(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
            B{k} = cell([layers.dimensions.B(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
            dU{k} = cell([layers.dimensions.U(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
            dV{k} = cell([layers.dimensions.V(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
            dB{k} = cell([layers.dimensions.B(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
            delta{k} = cell([layers.dimensions.B(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
            N{k + 1} = cell([layers.dimensions.B(k, :), layers.num_neurons(k + 1)]);
            H{k + 1} = cell([layers.dimensions.B(k, :), layers.num_neurons(k + 1)]);
            for (j = 1:layers.num_neurons(k + 1))
                for (i = 1:layers.num_neurons(k))
                    U{1, k}(:, :, i, j) = m2c(randrange_array(layers.dimensions.U(k, :), rand_dim));
                    V{1, k}(:, :, i, j) = m2c(randrange_array(layers.dimensions.V(k, :), rand_dim));
                    B{1, k}(:, :, i, j) = m2c(randrange_array(layers.dimensions.B(k, :), rand_dim));
                end
            end
        end
    end

    % Initialize zeroeth layer neuron outputs to be training input
    H{1, 1} = m2c(X_sims(:, :, n));
    
    % Forward pass through hidden layers
    for (k = 1:num_hidden)
        for (j = 1:layers.num_neurons(k + 1))
            N{1, k + 1}(:, :, j) = m2c(sum((mtimesx(mtimesx(c2m(U{1, k}(:, :, :, j)), c2m(H{1, k}(:, :, :))), t3(c2m(V{1, k}(:, :, :, j)))) ...
                + c2m(B{1, k}(:, :, :, j))), 3));
            H{1, k + 1}(:, :, j) = m2c(sigmoid(c2m(N{1, k + 1}(:, :, j))));
        end
    end
    L_hat(:, :, n) = c2m(N{1, num_hidden + 1});
    % Calculate error of prediction (MSE with Frobenius norm)
    error(n) = se_frob(L_hat(:, :, n), L_target(:, :, n));
    
    
    for (j = 1:layers.num_neurons(num_hidden + 1))
        for (i = 1:layers.num_neurons(num_hidden))
            delta{1, num_hidden}(:, :, i, j) = m2c((c2m(H{1, num_hidden + 1}) - sigmoid(L_target(:, :, n))).*(c2m(H{1, num_hidden + 1}).*(1 - c2m(H{1, num_hidden + 1}))));
            dU{1, num_hidden}(:, :, i, j) = m2c(c2m(delta{1, num_hidden}(:, :, i, j))*c2m(V{1, num_hidden}(:, :, i, j))*t3(c2m(H{1, num_hidden}(:, :, i))));
            dV{1, num_hidden}(:, :, i, j) = m2c(t3(c2m(delta{1, num_hidden}(:, :, i, j)))*c2m(U{1, num_hidden}(:, :, i, j))*c2m(H{1, num_hidden}(:, :, i)));
            dB{1, num_hidden}(:, :, i, j) = delta{1, num_hidden}(:, :, i, j);
        end
    end
    
    for (k = (num_hidden - 1):-1:1)
        for (j = 1:layers.num_neurons(k + 1))
            for (i = 1:layers.num_neurons(k))
                delta{1, k}(:, :, i, j) = m2c(sum(mtimesx(mtimesx(permute(c2m(U{1, k + 1}(:, :, j, :)), [2 1 3 4]), (c2m(delta{1, k + 1}(:, :, j, :)))), (c2m(V{1, k + 1}(:, :, j, :)))), 4) ...
                    .*c2m(H{1, k + 1}(:, :, j)).*(1 - c2m(H{1, k + 1}(:, :, j))));
                dU{1, k}(:, :, i, j) = m2c(c2m(delta{1, k}(:, :, i, j))*c2m(V{1, k}(:, :, i, j))*t3(c2m(H{1, k}(:, :, i))));
                dV{1, k}(:, :, i, j) = m2c(t3(c2m(delta{1, k}(:, :, i, j)))*c2m(U{1, k}(:, :, i, j))*c2m(H{1, k}(:, :, i)));
                dB{1, k}(:, :, i, j) = delta{1, k}(:, :, i, j);
            end
        end
    end
    
    for (k = (num_hidden):-1:1)
        for (j = 1:layers.num_neurons(k + 1))
            for (i = 1:layers.num_neurons(k))
                U{1, k}(:, :, i, j) = m2c(c2m(U{1, k}(:, :, i, j)) - (lr*c2m(dU{1, k}(:, :, i, j))));
                V{1, k}(:, :, i, j) = m2c(c2m(V{1, k}(:, :, i, j)) - (lr*c2m(dV{1, k}(:, :, i, j))));
                B{1, k}(:, :, i, j) = m2c(c2m(B{1, k}(:, :, i, j)) - (lr*c2m(dB{1, k}(:, :, i, j))));
            end
        end
    end
end

toc;
% end