function fig_name = get_fig_name(subfolder, protocol, L_hash, extension)
    fig_name = strcat('./figs/', subfolder, '/', protocol, '_', L_hash, '.', extension);
end