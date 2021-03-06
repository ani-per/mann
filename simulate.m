function [T, X] = simulate(odefun, L, t_range, L_hash, depict, xbounds, run_count, colors, fig_size, font_size)
    n = size(L, 1);
    xbounds = [0, 1];
    x0 = randrange(n, xbounds);
    
    % Simulation
    [T, X] = ode45(odefun, t_range, x0, [], L);
    
    % Figure generation if desired
    if (depict)
        fh = figure();
        for i = 1:n
            hold on;
            plot(T, X(:, i), 'LineWidth', 2.5, 'Color', colors(i, :));
        end
        fh.Position = fig_size;
        xlabel('Time [t] (s)', 'Interpreter', 'Latex', 'FontSize', font_size)
        ylabel('Position [x] (m)', 'Interpreter', 'Latex', 'FontSize', font_size)
        title({'Position [x] vs. Time [t] (s)'; "L (size " + n + "): " + L_hash}, 'Interpreter', 'Latex', 'FontSize', font_size)
        % legend(member_names, 'Location', 'northeastoutside', 'Interpreter', 'Latex', 'FontSize', font_size);
        ylim(xbounds);
        grid on;
        root = fullfile(pwd, "figs", "local_consensus", n + "_nodes");
        if (~exist(root, 'dir'))
            mkdir(root);
        end
        export_fig(get_fig_name(root, L_hash, run_count, "png"));
        close(fh)
    end
    
end