function out = listpatches
% List the patches in the active garden
%
% matpatch.listpatches
% patchNames = matpatch.listpatches
%
% Lists the patches in the active garden. If output is captured, returns a list
% of their names. If output is not captured, displays a listing to the console.

out = [];

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

if nargout == 0
  disp(details);
  clear out
end

