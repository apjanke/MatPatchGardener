function dig(name)
% DIG Dig up space for a new patch in your active garden
%
% This creates a new patch in your active garden, and activates it. The new
% patch is initially empty; you can add files to it with matpatch.plant.

garden = matpatch.Shed.activeGarden;
patch = garden.newPatch(name);
if isempty(patch)
  return
end

matpatch.Shed.activePatchName(name);




