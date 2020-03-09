function error_hist_train(error_vector, error_type, num_bins, fig_size, font_size, num_nodes, num_sims, num_epochs)
        fprintf('Training Results Histogram: %s\n', error_type)
        if strcmp(error_type, 'raw')
            hist_ylabel = 'Error Before Rounding';
            hist_title = {sprintf('Train Error Histogram (%d Nodes, %d Cases)', num_nodes, length(error_vector)/num_epochs); ...
                'Error Before Rounding'};
        elseif strcmp(error_type, 'ripe')
            hist_ylabel = 'Error After Rounding to Nearest Integer';
            hist_title = {sprintf('Train Error Histogram (%d Nodes, %d Cases)', num_nodes, length(error_vector)/num_epochs); ...
                'Error After Rounding to Nearest Integer'};
        elseif strcmp(error_type, 'real')
            hist_ylabel = 'Error After Rounding to Nearest Valid Laplacian';
            hist_title = {sprintf('Train Error Histogram (%d Nodes, %d Cases)', num_nodes, length(error_vector)/num_epochs); ...
                'Error After Rounding to Nearest Valid Laplacian'};
        end
        
        h = figure();
        h.Position = fig_size;
        
        % Histogram generation
        [N, C] = hist3(error_vector, [max(error_vector(:, 1)), num_bins]);
        imagesc(1:1:max(error_vector(:, 1)), C{2}, N');
        colormap(linspecer);
        cb = colorbar;
        
        % Axis tidying
        xlim([0 max(error_vector(:, 1))] + 0.5);
        xticks(1:max(error_vector(:, 1)));
        y_ticks = linspace(min(error_vector(:, 2)), max(error_vector(:, 2)), length(C{2}) + 1);
        yticks(y_ticks(2:3:end));
        yticklabels(sprintfc('%.1f', y_ticks(2:3:end)))
        
        % Thick grids
        hold on;
        g_y = y_ticks;
        g_x = (0:1:(max(error_vector(:, 1)) + 0.5)) + 0.5;
        for i = 2:length(g_x) - 1
           plot([g_x(i) g_x(i)], [g_y(1) g_y(end)], 'k', 'LineWidth', 1.75)
        end
        for i = 2:length(g_y) - 1
           plot([g_x(1) g_x(end)], [g_y(i) g_y(i)], 'k', 'LineWidth', 1.75)
        end
        
        % Legend tidying
        set(cb, 'XTickLabel', sprintfc('%0.0f%%', (100*(get(cb, 'XTick')/sum(error_vector(:, 1) == 1)))))
        
        % Figure properties
        set(gca, 'YDir', 'normal');
        set(gca, 'FontSize', font_size*0.75);
        xlabel('Epoch', 'Interpreter', 'Latex', 'FontSize', font_size);
        ylabel(hist_ylabel, 'Interpreter', 'Latex', 'FontSize', font_size);
        title(hist_title, 'Interpreter', 'Latex', 'FontSize', font_size*1.25);
        
        % Exporting
        root = fullfile(pwd, 'figs', 'local_consensus', 'hist', 'train', sprintf('%d_nodes', num_nodes));
        smart_mkdir(root);
        hist_filepath = fullfile(root, sprintf('train_error_hist_%d_nodes_%d_sims_%s.png', num_nodes, num_sims, error_type));
        export_fig(hist_filepath);
        close(h);
end