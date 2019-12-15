function error_hist_test(error_vector, error_type, num_bins, fig_size, font_size)
        if strcmp(error_type, 'raw')
            hist_xlabel = 'Error Before Rounding';
            hist_title = {strcat('Test Error Histogram (', int2str(length(error_vector)), " Cases)"); 'Error Before Rounding'};
        elseif strcmp(error_type, 'ripe')
            hist_xlabel = 'Error After Rounding';
            hist_title = {strcat('Test Error Histogram (', int2str(length(error_vector)), " Cases)"); 'Error After Rounding'};
        end
        h = figure();
        h.Position = fig_size;
        histogram(error_vector, num_bins);
        x_ticks = linspace(min(error_vector), max(error_vector), num_bins + 1);
        set(gca, 'FontSize', font_size*0.75);
        xticks(x_ticks(2:5:end));
        xtickformat('%.1f');
        yticklabels(100*(yticks)/length(error_vector));
        xlabel(hist_xlabel, 'Interpreter', 'Latex', 'FontSize', font_size);
        ylabel('Percentage of Test Cases', 'Interpreter', 'Latex', 'FontSize', font_size);
        title(hist_title, 'Interpreter', 'Latex', 'FontSize', font_size*1.25);
        export_fig(strcat('./figs/test_error_histogram_', error_type, '.png'), '-nocrop');
        close(h);
end