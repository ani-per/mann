function f = sigmoid(x)
    f = (1 + exp(-x)).^(-1);
end