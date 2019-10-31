function r = randrange(rlen, rbounds)
    assert(range(rbounds) > 0, "Identical bounds.");
    r = (max(rbounds) - min(rbounds)).*rand(rlen, 1) + min(rbounds);
    assert((min(r) > min(rbounds)) && (max(r) < max(rbounds)), "Incorrect generation.");
end