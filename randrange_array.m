function r = randrange_array(dim, rbounds)
    assert(range(rbounds) > 0, "Identical bounds.");
    r = zeros(dim);
    for (i = 1:dim(1))
        r(i,:) = (max(rbounds) - min(rbounds)).*rand(dim(2), 1) + min(rbounds);
    end
    assert((min(r, [], 'all') > min(rbounds)) && (max(r, [], 'all') < max(rbounds)), "Incorrect generation.");
end