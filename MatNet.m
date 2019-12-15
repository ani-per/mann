classdef MatNet < handle
    properties
        epoch % Counter of number of times the network has been trained with one data set
        layers % Structure containing sizees and corresponding dimensions of layers
        num_hidden % Number of hidden layers; output layer considered a hidden layer
        
        % Connection Weights
        U
        V
        B
        
        % Neuron Outputs
        N
        H
        
        % Backpropagation Parameters
        delta
        dU
        dV
        dB
        
        L_hat % Target Matrix
        error_raw % Array of Frobenius-normed error for each batch at each epoch before rounding
        now_error_raw % Most recent batch Frobenius-normed error before rounding
        error_ripe % Array of Frobenius-normed error for each batch at each epoch after rounding
        now_error_ripe % Most recent batch Frobenius-normed error after rounding
        
    end
    methods
        function obj = MatNet(layers, rand_dim)
            obj.epoch = 0;
            obj.layers = layers;
            obj.num_hidden = length(layers.num_neurons) - 1;
            
            % Initialize connection weights
            obj.U = cell(1, obj.num_hidden);
            obj.V = cell(1, obj.num_hidden);
            obj.B = cell(1, obj.num_hidden);
            obj.dU = cell(1, obj.num_hidden);
            obj.dV = cell(1, obj.num_hidden);
            obj.dB = cell(1, obj.num_hidden);
            obj.delta = cell(1, obj.num_hidden);
            
            % Initialize neuron outputs
            obj.N = cell(1, obj.num_hidden + 1);
            obj.H = cell(1, obj.num_hidden + 1);
            
            % Set up empty hidden layer structure
            for (k = 1:obj.num_hidden)
                obj.U{k} = cell([layers.dimensions.U(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
                obj.V{k} = cell([layers.dimensions.V(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
                obj.B{k} = cell([layers.dimensions.B(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
                obj.dU{k} = cell([layers.dimensions.U(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
                obj.dV{k} = cell([layers.dimensions.V(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
                obj.dB{k} = cell([layers.dimensions.B(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
                obj.delta{k} = cell([layers.dimensions.B(k, :), layers.num_neurons(k), layers.num_neurons(k + 1)]);
                obj.N{k + 1} = cell([layers.dimensions.B(k, :), layers.num_neurons(k + 1)]);
                obj.H{k + 1} = cell([layers.dimensions.B(k, :), layers.num_neurons(k + 1)]);
                for (j = 1:layers.num_neurons(k + 1))
                    for (i = 1:layers.num_neurons(k))
                        obj.U{1, k}(:, :, i, j) = m2c(randrange_array(layers.dimensions.U(k, :), rand_dim));
                        obj.V{1, k}(:, :, i, j) = m2c(randrange_array(layers.dimensions.V(k, :), rand_dim));
                        obj.B{1, k}(:, :, i, j) = m2c(randrange_array(layers.dimensions.B(k, :), rand_dim));
                    end
                end
            end
            
            % Array for storing error at each epoch
            obj.error_raw = {};
            obj.error_ripe = {};
            % Error of most recent batch of most recent epoch
            obj.now_error_raw = [1e5];
            obj.now_error_ripe = [1e5];
            % Array for storing predicted L for each batch
            obj.L_hat = {};
        end
        
        function reset_epoch(obj)
            obj.epoch = 0;
        end
        
        function reset(obj)
            obj.epoch = 0;
            obj.error_raw = {};
            obj.error_ripe = {};
            obj.now_error_raw = [];
            obj.now_error_ripe = [];
            obj.L_hat = {};
        end
        
        function train(obj, X_sims, L_target, lr)
%             if (obj.epoch > 0 && any(cellfun('isempty', obj.error_raw{obj.epoch})))
%                 obj.reset
%             end
            assert(size(X_sims, 3) == size(L_target, 3));
            dataset_length = size(X_sims, 3);
            obj.epoch = obj.epoch + 1;
            
            obj.error_raw{obj.epoch} = cell(dataset_length, 1);
            obj.error_ripe{obj.epoch} = cell(dataset_length, 1);
            obj.L_hat{obj.epoch} = cell(size(L_target));
            
            tic
            for (batch = 1:25)
                % Initialize zeroeth layer neuron outputs to be training input
                obj.H{1, 1} = m2c(X_sims(:, :, batch));

                % Forward pass through hidden obj.layers
                for (k = 1:obj.num_hidden)
                    for (j = 1:obj.layers.num_neurons(k + 1))
                        obj.N{1, k + 1}(:, :, j) = m2c(sum((mtimesx(mtimesx(c2m(obj.U{1, k}(:, :, :, j)), c2m(obj.H{1, k}(:, :, :))), ...
                            t3(c2m(obj.V{1, k}(:, :, :, j)))) + c2m(obj.B{1, k}(:, :, :, j))), 3));
                        obj.H{1, k + 1}(:, :, j) = m2c(sigmoid(c2m(obj.N{1, k + 1}(:, :, j))));
                    end
                end
                obj.L_hat{obj.epoch}(:, :, batch) = obj.N{1, obj.num_hidden + 1};
                % Calculate error of prediction (MSE with Frobenius norm) before rounding
                obj.error_raw{obj.epoch}(batch) = m2c(se_frob(c2m(obj.L_hat{obj.epoch}(:, :, batch)), L_target(:, :, batch)));
                obj.error_ripe{obj.epoch}(batch) = m2c(se_frob(round(c2m(obj.L_hat{obj.epoch}(:, :, batch))), L_target(:, :, batch)));

                for (j = 1:obj.layers.num_neurons(obj.num_hidden + 1))
                    for (i = 1:obj.layers.num_neurons(obj.num_hidden))
                        obj.delta{1, obj.num_hidden}(:, :, i, j) = m2c((c2m(obj.H{1, obj.num_hidden + 1}) - ...
                            sigmoid(L_target(:, :, batch))).*(c2m(obj.H{1, obj.num_hidden + 1}).*(1 - c2m(obj.H{1, obj.num_hidden + 1}))));
                        obj.dU{1, obj.num_hidden}(:, :, i, j) = ...
                            m2c(c2m(obj.delta{1, obj.num_hidden}(:, :, i, j))*c2m(obj.V{1, obj.num_hidden}(:, :, i, j))*t3(c2m(obj.H{1, obj.num_hidden}(:, :, i))));
                        obj.dV{1, obj.num_hidden}(:, :, i, j) = ...
                            m2c(t3(c2m(obj.delta{1, obj.num_hidden}(:, :, i, j)))*c2m(obj.U{1, obj.num_hidden}(:, :, i, j))*c2m(obj.H{1, obj.num_hidden}(:, :, i)));
                        obj.dB{1, obj.num_hidden}(:, :, i, j) = obj.delta{1, obj.num_hidden}(:, :, i, j);
                    end
                end

                for (k = (obj.num_hidden - 1):-1:1)
                    for (j = 1:obj.layers.num_neurons(k + 1))
                        for (i = 1:obj.layers.num_neurons(k))
                            obj.delta{1, k}(:, :, i, j) = m2c(sum(mtimesx(mtimesx(permute(c2m(obj.U{1, k + 1}(:, :, j, :)), [2 1 3 4]), ...
                                (c2m(obj.delta{1, k + 1}(:, :, j, :)))), (c2m(obj.V{1, k + 1}(:, :, j, :)))), 4) ...
                                .*c2m(obj.H{1, k + 1}(:, :, j)).*(1 - c2m(obj.H{1, k + 1}(:, :, j))));
                            obj.dU{1, k}(:, :, i, j) = m2c(c2m(obj.delta{1, k}(:, :, i, j))*c2m(obj.V{1, k}(:, :, i, j))*t3(c2m(obj.H{1, k}(:, :, i))));
                            obj.dV{1, k}(:, :, i, j) = m2c(t3(c2m(obj.delta{1, k}(:, :, i, j)))*c2m(obj.U{1, k}(:, :, i, j))*c2m(obj.H{1, k}(:, :, i)));
                            obj.dB{1, k}(:, :, i, j) = obj.delta{1, k}(:, :, i, j);
                        end
                    end
                end

                for (k = (obj.num_hidden):-1:1)
                    for (j = 1:obj.layers.num_neurons(k + 1))
                        for (i = 1:obj.layers.num_neurons(k))
                            obj.U{1, k}(:, :, i, j) = m2c(c2m(obj.U{1, k}(:, :, i, j)) - (lr*c2m(obj.dU{1, k}(:, :, i, j))));
                            obj.V{1, k}(:, :, i, j) = m2c(c2m(obj.V{1, k}(:, :, i, j)) - (lr*c2m(obj.dV{1, k}(:, :, i, j))));
                            obj.B{1, k}(:, :, i, j) = m2c(c2m(obj.B{1, k}(:, :, i, j)) - (lr*c2m(obj.dB{1, k}(:, :, i, j))));
                        end
                    end
                end
                
                obj.now_error_raw(obj.epoch) = mean(c2m(obj.error_raw{obj.epoch}));
                obj.now_error_ripe(obj.epoch) = mean(c2m(obj.error_ripe{obj.epoch}));
            end
            toc
        end
        
        function train_batch(obj, X_sims, L_target, lr, num_epochs, tolerance)
            if (obj.epoch == 0)
                obj.train(X_sims, L_target, lr)
                disp(obj.epoch)
                disp(obj.now_error_raw(obj.epoch))
                disp(obj.now_error_ripe(obj.epoch))
            end
            while (obj.epoch <= (num_epochs - 1) && abs(obj.now_error_ripe(obj.epoch)) > tolerance)
                obj.train(X_sims, L_target, lr)
                disp(obj.epoch)
                disp(obj.now_error_raw(obj.epoch))
                disp(obj.now_error_ripe(obj.epoch))
            end
        end
    end
end