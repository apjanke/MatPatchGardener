function mp_plant(varargin)
% MP_PLANT Plant new files in your active patch
%
% mp_plant <fcn> ...
%
% Plants the named files in your active patch from the Matlab installation. The
% files may be specified as function names or class names.
%
% This is a convenience wrapper around MATPATCH.PLANT that lets you call it in
% command form.
%
% Examples:
%
% mp_plant mean
% mp_plant datetime duration
%
% See also:
% MATPATCH.PLANT

allthings = string.empty;
for i = 1:numel(varargin)
  allthings = [allthings string(varargin{i})]; %#ok<AGROW>
end

matpatch.plant(allthings);