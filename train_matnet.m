% function train_matnet(X_sims, L_target, layers, learning_rate, num_epochs)
    % k : layer number
    % j : neuron number
    % i : local weight number
    U = cell(1, (length(layers.num_neurons) - 1));
    V = cell(1, (length(layers.num_neurons) - 1));
    B = cell(1, (length(layers.num_neurons) - 1));
    N = cell(1, (length(layers.num_neurons) - 1));
    H = cell(1, (length(layers.num_neurons) - 1));
    % Initialize connection weights
    for (k = 1:(length(layers.num_neurons) - 1))
        U{k} = cell([layers.dimensions.U(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
        V{k} = cell([layers.dimensions.V(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
        B{k} = cell([layers.dimensions.B(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
        N{k} = cell([layers.dimensions.B(k, :), layers.num_neurons(k + 1)]);
        H{k} = cell([layers.dimensions.B(k, :), layers.num_neurons(k + 1)]);
        for (j = 1:layers.num_neurons(k + 1))
            for (i = 1:layers.num_neurons(k))
                U{1, k}(:, :, i, j) = num2cell(randn(layers.dimensions.U(k, :)));
                V{1, k}(:, :, i, j) = num2cell(randn(layers.dimensions.V(k, :)));
                B{1, k}(:, :, i, j) = num2cell(randn(layers.dimensions.B(k, :)));
            end
        end
    end
    
    for (n = 1:1)
        for (j = 1:layers.num_neurons(2))
            N{1, 1}(:, :, j) = m2c(mtimesx(mtimesx(c2m(U{1, 1}(:, :, :, j)), X_sims(:, :, n)), t3(c2m(V{1, 1}(:, :, :, j)))));
            H{1, 1}(:, :, j) = m2c(sigmoid(c2m(N{1, 1}(:, :, j))));
        end
        for (k = 2:(length(layers.num_neurons) - 1))
            for (j = 1:layers.num_neurons(k + 1))
                N{1, k}(:, :, j) = m2c(sum((mtimesx(mtimesx(c2m(U{1, k}(:, :, :, j)), c2m(H{1, k - 1}(:, :, :))), t3(c2m(V{1, k}(:, :, :, j)))) ...
                    + c2m(B{1, k}(:, :, :, j))), 3));
                H{1, k}(:, :, j) = m2c(sigmoid(c2m(N{1, k}(:, :, j))));
            end
        end
    end
% end