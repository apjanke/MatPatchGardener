function activate(patchNameOrPrefix)
% ACTIVATE Activate a named patch so that's what you're working on
%
% matpatch.activate(patchNameOrPrefix)
%
% Activates a given patch.
%
% PatchNameOrPrefix is the name of a patch, or the leading substring of a patch
% name that uniquely identifies a patch within the active garden. Errors if a
% substring has multiple matches.
%
% The activated patch becomes the default target for subsequent operations like
% plant().

% TODO: What about when one patch name is actually a leading prefix of another
% patch name? Exact matches should take precedence over multiple prefix matches.

targ = patchNameOrPrefix;
garden = matpatch.Shed.activeGarden;
patchNames = garden.listPatches;

ix = find(startsWith(lower(patchNames), lower(targ)));
if isempty(ix)
  mperror("No matching patch for '%s' in your garden at '%s'", ...
    targ, garden.dir);
  return
end
if numel(ix) > 1
  mperror("Multiple patches in your garden matched '%s': %s", ...
    targ, strjoin(patchNames(ix), ", "));
end
patchName = patchNames(ix);

matpatch.Shed.activatePatch(patchName);

logger.info("Now gardening patch %s", patchName);
