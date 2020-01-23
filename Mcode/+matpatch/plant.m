function plant(varargin)
%PLANT Plant more files in your active patch
%
% matpatch.plant(varargin)
%
% Each varargin may be a char or string array of some sort. All the varargins
% are combined to come up with the list of things to plant.
%
% The things to plant may be function names, class names, or maybe something
% else that resolves to a path using which().
%
% The files are copied from your Matlab installation into your active patch's
% code files directory.
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

