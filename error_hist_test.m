function error_hist_test(error_vector, error_type, num_bins, fig_size, font_size, num_nodes, num_sims)
        fprintf('Test Results Histogram: %s\n', error_type)
        if strcmp(error_type, 'raw')
            hist_xlabel = 'Error Before Rounding';
            hist_title = {sprintf('Test Error Histogram (%d Nodes, %d Cases)', num_nodes, length(error_vector)); ...
                'Error Before Rounding'};
        elseif strcmp(error_type, 'ripe')
            hist_xlabel = 'Error After Rounding to Nearest Integer';
            hist_title = {sprintf('Test Error Histogram (%d Nodes, %d Cases)', num_nodes, length(error_vector)); ...
                'Error After Rounding to Nearest Integer'};
        elseif strcmp(error_type, 'real')
            hist_xlabel = 'Error After Rounding to Nearest Valid Laplacian';
            hist_title = {sprintf('Test Error Histogram (%d Nodes, %d Cases)', num_nodes, length(error_vector)); ...
                'Error After Rounding to Nearest Valid Laplacian'};
        end
        
        h = figure();
        h.Position = fig_size;
        
        % Histogram generation
        edges = linspace(min(error_vector), max(error_vector), num_bins + 1);
        histogram(error_vector, edges);
        
        % Axis tidying
        x_ticks_all = linspace(min(error_vector), max(error_vector), 2*num_bins + 1);
        x_ticks = x_ticks_all(2:2*floor(num_bins^(1/2)):end);
        xticks(x_ticks);
        xticklabels(sprintfc('%.1f', xticks))
        yticklabels(sprintfc('%.1f%%', 100*(yticks)/length(error_vector)))
        
        % Figure properties
        set(gca, 'FontSize', font_size*0.75);
        xlabel(hist_xlabel, 'Interpreter', 'Latex', 'FontSize', font_size);
        ylabel('Percentage of Test Cases', 'Interpreter', 'Latex', 'FontSize', font_size);
        title(hist_title, 'Interpreter', 'Latex', 'FontSize', font_size*1.25);
        
        % Exporting
        root = fullfile(pwd, 'figs', 'local_consensus', 'hist', 'test', sprintf('%d_nodes', num_nodes));
        smart_mkdir(root);
        hist_filepath = fullfile(root, sprintf('error_hist_%d_nodes_%d_sims_%s.png', num_nodes, num_sims, error_type));
        export_fig(hist_filepath, '-nocrop');
        close(h);
end