function L_list = generate_L_undirected(n)
    % Source for algorithm: https://stackoverflow.com/a/35292981
    m = n*(n-1)/2;
    offdiags = dec2bin(0:(2^m - 1), m) - 48;
    ignore = length(offdiags) - length(offdiags(mean(offdiags, 2) > 0, :));
    offdiags = offdiags(mean(offdiags, 2) > 0, :);
    L_list = zeros(n, n, 2^m - ignore);
    [ind_i, ind_j, ~] = meshgrid(1:n, 1:n, 1:(2^m - ignore));
    L_list(ind_i > ind_j) = offdiags.';
    L_list = L_list + permute(L_list, [2 1 3]);
    % Remove all Laplacians that have at least one all-zero row (i.e. at least one disconnected node)
    L_list = L_list(:, :, all(any(L_list, 2)));
end