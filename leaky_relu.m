function f = leaky_relu(x)
    f = x;
    f(f <= 0) = 0.01*f(f <= 0);
end