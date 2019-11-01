function [T, X] = simulate(odefun, L, t_range, L_hash, xbounds, depict, run_count, colors, fig_size, font_size)

    xbounds = [0, 1];
    x0 = randrange(length(L), xbounds);
    
    % Simulation
    [T, X] = ode45(odefun, t_range, x0, [], L);

    % Figure generation if desired
    if (depict)
        fh = figure();
        for i = 1:length(L)
            hold on;
            plot(T, X(:, i), 'LineWidth', 2.5, 'Color', colors(i, :));
        end
        fh.Position = fig_size;
        xlabel('Time [t] (s)', 'Interpreter', 'Latex', 'FontSize', font_size)
        ylabel('Position [x] (m)', 'Interpreter', 'Latex', 'FontSize', font_size)
        title('Position [x] vs. Time [t] (s)', 'Interpreter', 'Latex', 'FontSize', font_size)
        % legend(member_names, 'Location', 'northeastoutside', 'Interpreter', 'Latex', 'FontSize', font_size);
        ylim(xbounds);
        grid on;
        if (~exist(get_subfolder_name('local_consensus'), 'dir'))
            mkdir(get_subfolder_name('local_consensus'));
        end
        export_fig(get_fig_name('local_consensus', 'lc', L_hash, int2str(run_count), 'png'));
        close(fh)
    end
    
end