function flist = findfiles(pattern,basedir)
% Recursively finds all instances of files and folders with a naming pattern
%
% FLIST = FINDFILES(PATTERN) returns a cell array of all files and folders
% matching the naming PATTERN in the current folder and all folders below
% it in the directory structure. The PATTERN is specified as a char, and
% can include standard file-matching ("globbing") wildcards.
%
% FLIST = FINDFILES(PATTERN, BASEDIR) finds the files starting at the
% BASEDIR folder instead of the current folder. BASEDIR is a char.
%
% Returns a cellstr column vector or empty.
%
% Examples:
% Find all MATLAB code files in and below the current folder:
%   >> files = findfiles('*.m');
% Find all files and folders starting with "matlab"
%   >> files = findfiles('matlab*');
% Find all MAT-files in and below the folder C:\myfolder
%   >> files = findfiles('*.mat', 'C:\myfolder');
%
% Copyright 2016 The MathWorks, Inc.

% Maybe need to add extra bulletproofing for stupid things like
% findfiles('.*')

% Input check
if nargin < 2
    basedir = pwd;
end
if isstring(pattern)
  mustBeScalar(pattern);
  pattern = char(pattern);
end
if isstring(basedir)
  mustBeScalar(basedir);
  basedir = char(basedir);
end
if ~ischar(pattern) || ~ischar(basedir)
    error('File name pattern and base folder must be specified as chars')
end
if ~isfolder(basedir)
    error(['Nonexistent folder: "',basedir,'"'])
end

% Get full-file specification of search pattern
fullpatt = [basedir filesep pattern];

%logger.debug("Checking basedir: %s", basedir);

% Get list of all folders in BASEDIR
d = readdir(basedir);
d(~cellfun(@isfolder,strcat(basedir,filesep,d))) = [];

% Check for a direct match in BASEDIR
% (Covers the possibility of a folder with the name of PATTERN in BASEDIR)
if any(strcmp(d, pattern))
    % If so, that's our match
    flist = {fullpatt};
else
    % If not, do a directory listing
    f = listfiles(fullpatt);
    if isempty(f)
        flist = {};
    else
        flist = strcat(basedir, filesep, cellstr(f));
    end
end

% Recursively go through folders in BASEDIR
for k = 1:length(d)
    flist = [flist; findfiles(pattern, [basedir,filesep,d{k}])]; %#ok<AGROW>
end
flist = flist(:);

end

function out = listfiles(patt)
d = dir(patt);
tf = ismember({d.name}, {'.' '..'});
d(tf) = [];
out = {d.name};
out = out(:);
end

function out = readdir(pth)
d = dir(pth);
tf = ismember({d.name}, {'.' '..'});
d(tf) = [];
out = {d.name};
end