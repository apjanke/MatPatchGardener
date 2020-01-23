function activate(patchNameOrPrefix)
% Activate a named patch
%
% The activated patch becomes the default target for subsequent operations like
% plant().

targ = patchNameOrPrefix;
garden = matpatch.Shed.currentGarden;
patches = garden.listPatches;

ix = find(startsWith(lower(patches), lower(targ)));
if isempty(ix)
  matpatch.error("No matching patch for '%s' in your garden at '%s'", ...
    targ, garden.dir);
  return
end
if numel(ix) > 1
  matpatch.error("Multiple patches in your garden matched '%s': %s", ...
    targ, strjoin(patches(ix), ", "));
end

patch = patches(ix);

matpatch.Shed.activePatch(patch);

log.info("Walked over to patch %s", patch);
