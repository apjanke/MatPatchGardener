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
fprintf('Active patch: %s\n', matpatch.Shed.activePatchName);
fprintf('\n');

