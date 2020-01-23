function harvest
% HARVEST Collect your current patch's changes into a patch/diff file

patch = matpatch.Shed.activePatch;
if isempty(patch)
  mperror("No active patch!");
  return
end

patch.harvest;

end