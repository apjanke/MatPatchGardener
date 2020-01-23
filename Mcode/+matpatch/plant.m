function plant(varargin)
%PLANT Plant more files in your current patch

if isempty(matpatch.Shed.activePatchName)
  mperror("You do not have an active patch to plant things in!");
  return
end

patch = matpatch.Shed.activePatch;

allthings = string.empty;
for i = 1:numel(varargin)
  allthings = [allthings string(varargin{i})]; %#ok<AGROW>
end

patch.plant(allthings);

