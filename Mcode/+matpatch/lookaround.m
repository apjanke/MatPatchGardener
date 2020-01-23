function lookaround
% Look around the garden and see your current gardening status
%
% Displays the current MatPatchGardener status to the command window.

fprintf('\n');

garden = matpatch.Shed.activeGarden;

if isempty(garden)
  fprintf('You are not in a garden!\n');
  fprintf('\n');
  return
end

fprintf('Active garden: %s\n', garden.dir);
pname = matpatch.Shed.activePatchName;
if isempty(pname)
  fprintf('No active patch.\n');
else
  fprintf('Active patch: %s\n', pname);
end

fprintf('\n');
