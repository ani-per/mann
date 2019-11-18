function r = randrange_disc(rlen, rbounds)
    assert(range(rbounds) > 0, "Identical bounds.");
    r = [min(rbounds); (max(rbounds) - min(rbounds)).*rand(rlen - 2, 1) + min(rbounds); max(rbounds)];
    assert((min(r) >= min(rbounds)) && (max(r) <= max(rbounds)), "Incorrect generation.");
end