function [train, test] = split_sims(sims, train_frac)
    train = sims(:, :, 1:floor(train_frac*end));
    test = sims(:, :, ceil(train_frac*end):end);
end