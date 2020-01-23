function activate(patchNameOrPrefix)
% ACTIVATE Activate a named patch so that's what you're working on
%
% The activated patch becomes the default target for subsequent operations like
% plant().

targ = patchNameOrPrefix;
garden = matpatch.Shed.activeGarden;
patches = garden.listPatches;

ix = find(startsWith(lower(patches), lower(targ)));
if isempty(ix)
  mperror("No matching patch for '%s' in your garden at '%s'", ...
    targ, garden.dir);
  return
end
if numel(ix) > 1
  mperror("Multiple patches in your garden matched '%s': %s", ...
    targ, strjoin(patches(ix), ", "));
end

patch = patches(ix);
patch.activate;

log.info("Walked over to patch %s", patch);
