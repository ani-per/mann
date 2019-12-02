function loss = se_frob(Y, X)
    assert(size(Y, 1) == size(X, 1) && size(Y, 2) == size(X, 2))
    loss = (1/2)*((norm(Y - X))^2);
end