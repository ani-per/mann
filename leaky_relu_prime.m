function f = leaky_relu_prime(x)
    f = x;
    f(f <= 0) = 0.01*f(f < 0);
    f(f > 0) = 1;
end