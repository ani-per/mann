function fig_name = get_fig_name(subfolder, protocol, L_hash, run_count, extension)
    fig_name = strcat('./figs/', subfolder, '/', protocol, '_', L_hash, '_', run_count, '.', extension);
end