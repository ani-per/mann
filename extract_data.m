function [X_sims, L_target] = extract_data(sims)
    X_sims = cat(3, sims(:).X);
    L_target = cat(3, sims(:).L);
end