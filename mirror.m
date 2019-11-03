function X_mirror = mirror(X)
    %X _mirror = (X + X') - eye(size(X, 1)).*diag(X);
    X_mirror = X + tril(X, -1).';
end