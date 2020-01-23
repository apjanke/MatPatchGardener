function walkovertopatch
% Change directory to the files dir of the active patch

p = matpatch.Shed.activePatch;
if isempty(p)
  fprintf('\nNo active patch.\n\n');
  return
end

cd(p.filesDir);
fprintf('\nWalked over to %s\n\n', p.filesDir);
