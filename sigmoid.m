function sig = sigmoid(x)
    sig = (1 + exp(-x)).^(-1);
end