function harvest
% HARVEST Collect your active patch's changes into a patch/diff file
%
% matpatch.harvest
%
% Running harvest will examine the active patch for changes you've made, and
% collect them all into a patch file that you can share with other developers.

patch = matpatch.Shed.activePatch;
if isempty(patch)
  mperror("No active patch!");
  return
end

patch.harvest;

end