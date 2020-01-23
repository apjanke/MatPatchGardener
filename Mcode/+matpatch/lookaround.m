function lookaround
% Look around the garden and see your current gardening status
%
% Displays the current MatPatchGardener status to the command window.

fprintf('\n');

garden = matpatch.Shed.currentGarden;

if isempty(garden)
  fprintf('You are not in a garden!\n');
  return
end

fprintf('Active garden: %s\n', garden.dir);
fprintf('Active patch: %s\n', matpatch.Shed.activePatch);
fprintf('\n');

