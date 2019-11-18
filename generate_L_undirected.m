function L_list = generate_L_undirected(n)
    % Source for algorithm: https://stackoverflow.com/a/35292981
    m = n*(n-1)/2;
    offdiags = dec2bin(0:(2^m - 1), m) - 48;
    ignore = length(offdiags) - length(offdiags(mean(offdiags, 2) > 0, :));
    offdiags = offdiags(mean(offdiags, 2) > 0, :);
    A_list = zeros(n, n, 2^m - ignore);
    [ind_i, ind_j, ~] = meshgrid(1:n, 1:n, 1:(2^m - ignore));
    A_list(ind_i > ind_j) = offdiags.';
    A_list = A_list + permute(A_list, [2 1 3]);
    % Remove all Laplacians that have at least one all-zero row (i.e. at least one individually disconnected node)
    A_list = A_list(:, :, all(any(A_list, 2)));
    % Use squaring of sum of adjacency matrix and identity matrix to
    % identify disconnected graphs (check validity of this later)
    % Ref: https://math.stackexchange.com/a/864636, https://math.stackexchange.com/q/286808
    % A_list = A_list(:, :, any(all((A_list + eye(n)).^n)));
    % Calculate Laplacians of remaining (connected) adjacency matrices
    L_list = eye(n).*sum(A_list) - A_list;
    connected = false(size(L_list, 3), 1);
    for i = 1:size(L_list, 3)
        L_eigs = eig(L_list(:, :, i));
        fiedler = L_eigs(2);
        if (abs(fiedler) > 0.01)
            connected(i) = 1;
        else
            connected(i) = 0;
        end
    end
    L_list = L_list(:, :, connected);
    % Sequence of connected graphs with n vertices: http://oeis.org/A001187
end