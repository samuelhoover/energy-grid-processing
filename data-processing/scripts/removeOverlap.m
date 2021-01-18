function dset = removeOverlap(dset)
dset(dset >= 1E20) = nan;
end