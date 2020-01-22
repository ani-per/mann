function error_hist_test(error_vector, error_type, num_bins, fig_size, font_size, num_nodes, num_sims)
        if strcmp(error_type, 'raw')
            hist_xlabel = 'Error Before Rounding';
            hist_title = {sprintf('Test Error Histogram (%d Nodes, %d Cases)', num_nodes, length(error_vector)); 'Error Before Rounding'};
        elseif strcmp(error_type, 'ripe')
            hist_xlabel = 'Error After Rounding to Nearest Integer';
            hist_title = {sprintf('Test Error Histogram (%d Nodes, %d Cases)', num_nodes, length(error_vector)); 'Error After Rounding to Nearest Integer'};
        elseif strcmp(error_type, 'real')
            hist_xlabel = 'Error After Rounding to Nearest Valid Laplacian';
            hist_title = {sprintf('Test Error Histogram (%d Nodes, %d Cases)', num_nodes, length(error_vector)); 'Error After Rounding to Nearest Valid Laplacian'};
        end
        h = figure();
        h.Position = fig_size;
        histogram(error_vector, num_bins);
        x_ticks = linspace(min(error_vector), max(error_vector), num_bins + 1);
        set(gca, 'FontSize', font_size*0.75);
        xticks(x_ticks(2:5:end));
        xtickformat('%.1f');
        yticklabels(100*(yticks)/length(error_vector));
        ytickformat('%.1f');
        xlabel(hist_xlabel, 'Interpreter', 'Latex', 'FontSize', font_size);
        ylabel('Percentage of Test Cases', 'Interpreter', 'Latex', 'FontSize', font_size);
        title(hist_title, 'Interpreter', 'Latex', 'FontSize', font_size*1.25);
        root = fullfile(pwd, 'figs', 'local_consensus', 'hist', 'test');
        smart_mkdir(root);
        export_fig(fullfile(root, sprintf('error_hist_%d_nodes_%d_sims_%s.png', num_nodes, num_sims, error_type)), '-nocrop');
        close(h);
end