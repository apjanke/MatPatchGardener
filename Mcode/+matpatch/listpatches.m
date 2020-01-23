function out = listpatches
% List the patches in the active garden

garden = matpatch.Shed.activeGarden;
if isempty(garden)
  fprintf('No active garden.\n');
  return
end

[patches,details] = garden.listPatches;

if isempty(patches)
  fprintf('No patches in this garden.\n');
  return
end

disp(details);
