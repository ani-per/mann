function fig_name = get_fig_name(root, L_hash, run_count, extension)
    fig_name = char(fullfile(root, "L_" + L_hash + "_" + run_count + "." + extension));
end