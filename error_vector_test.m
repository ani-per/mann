function error_vector = error_vector_test(error_vals, error_type)
    if strcmp(error_type, 'raw')
        hist_ylabel = 'Error Before Rounding';
        hist_title = {"Error Histogram"; 'Error Before Rounding'};
    elseif strcmp(error_type, 'ripe')
        hist_ylabel = 'Error After Rounding';
        hist_title = {"Error Histogram"; 'Error After Rounding'};
    end
    error_vector = zeros(numel(error_vals), 2);
    error_vals
    for (i = 1:size(error_vals, 1))
        (1 + (i - 1)*size(error_vals, 1)):((i)*size(error_vals, 1));
        error_vector((1 + (i - 1)*size(error_vals, 1)):((i)*size(error_vals, 1))) = ...
            [repelem(i, size(error_vals, 2)); (error_vals(i, :))]';
    end
end