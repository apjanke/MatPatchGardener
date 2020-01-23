classdef Patch
  % A Patch is a set of changes to Matlab, stored in a directory
  
  % TODO: A function to list just the files that have diffs
  
  properties (SetAccess = private)
    name
    % Parent garden
    garden
    % Path to the patch dir
    dir
    filesDir
    infoFile
    patchFile
  end
  
  methods
    
    function this = Patch(garden, name, dir)
      % Create a new object looking at a patch directory
      %
      % obj = Patch(garden, name, dir)
      %
      % Dir is the path to the patch directory. It does not have to exist; this
      % object may be used to create the directory with the TILL method.
      if nargin == 0
        return
      end
      mustBeA(garden, 'matpatch.Garden');
      this.garden = garden;
      this.name = string(name);
      this.dir = string(dir);
      this.filesDir = fullfile(this.dir, 'files');
      this.infoFile = fullfile(this.dir, 'info.json');
      this.patchFile = fullfile(this.dir, [char(this.name) '.patch']);
    end
    
    function out = info(this)
      out = jsondecode(fileread(this.infoFile));
    end
    
    function dig(this)
      % Initialize the patch directory
      if isfolder(this.dir)
        error('Cannot initialize patch dir: dir already exists: %s', this.dir);
      end
      matpatch.Shed.mkdir(this.dir);
      matpatch.Shed.mkdir(this.filesDir);
      
      info = struct;
      info.MatlabVersion = matpatch.Shed.matlabVersion;
      info.CreatedOn = datestr(datetime);
      matpatch.Shed.spew(this.infoFile, jsonencode(info));
    end
    
    function plant(this, things)
      % PLANT Plant copies of Matlab's files in this patch, shadowing the originals
      things = string(things);
      things = things(:)';
      
      % TODO: Recognize and copy @class dirs, recursively
      % TODO: Remove read-only flags from planted files
      
      info = this.info;
      if ~isequal(info.MatlabVersion, matpatch.Shed.matlabVersion)
        mperror(['Cannot plant: this patch is against Matlab %s, but '...
          'you''re running under Matlab %s. Can''t mix versions in a patch.'], ...
          info.MatlabVersion, matpatch.Shed.matlabVersion);
        return;
      end
      
      relFiles = repmat(string(missing), size(things));
      for iThing = 1:numel(things)
        thing = things(iThing);
        w = which(thing);
        if isempty(w)
          % Might be a normal file?
          if isfile(thing)
            mperror("I don't know what to do with plain file paths: %s", thing);
          else
            mperror("Could not find thing: %s", thing);
          end
          return
        else
          if startsWith(w, matlabroot)
            % TODO: Check for @class dirs that we need to add
            relFiles(iThing) = w(numel(matlabroot)+2:end);
          elseif startsWith(w, 'built-in (')
            mperror("Cannot plant %s: it is a built-in", thing);
          else
            mperror("File for thing '%s' (%s) is not under matlabroot.", thing, w);
            return
          end
        end
      end
      tfMiss = ismissing(relFiles);
      relFiles(tfMiss) = [];
      things(tfMiss) = [];
      
      % See if we need to grab private directories, too
      privDirs = string.empty; % as relative paths
      classDirs = string.empty; % as relative paths
      for f = relFiles
        parentDir = fileparts(f);
        [~,parentDirBase] = fileparts(parentDir);
        privDir = fullfile(parentDir, 'private');
        if isfolder(privDir)
          privDirs(end+1) = privDir; %#ok<AGROW>
        end
        if parentDirBase(1) == '@'
          classDirs(end+1) = parentDir; %#ok<AGROW>
        end
      end
      privDirs = unique(privDirs);
      if ~isempty(classDirs)
        error('Uh oh! I don''t know how to handle @class dirs yet!');
      end
      
      % Okay, all things resolved to files
      for i = 1:numel(relFiles)
        f = relFiles(i);
        source = fullfile(matlabroot, f);
        dest = fullfile(this.filesDir, f);
        matpatch.Shed.mkdir(fileparts(dest));
        if isfile(dest)
          logger.info("File %s is already planted in patch", things(i));
        else
          copyfile(source, dest);
          logger.info("Planted %s at %s", things(i), f);
        end
      end
      if ~isempty(privDirs)
        logger.info("Grabbing %d private/ dirs, too:", numel(privDirs));
      end
      for i = 1:numel(privDirs)
        relDir = privDirs(i);
        absPrivDir = fullfile(matlabroot, relDir);
        dest = fullfile(this.filesDir, relDir);
        matpatch.Shed.cpr(absPrivDir, dest);
        logger.info("Planted %s at %s", relDir, dest);
      end
      
      % And now that we have new files, need to make sure that our paths are up
      % to date
      if this.isActive
        this.addToPath;
      end
    end
    
    function out = isActive(this)
      out = isequal(this.name, matpatch.Shed.activePatchName);
    end
    
    function activate(this)
      % ACTIVATE Activate this patch
      matpatch.Shed.activePatchName(this.name);
      this.addToPath;
    end
    
    function deactivate(this)
      % DEACTIVATE Deactivate this patch
      this.removeFromPath;
      matpatch.Shed.activePatchName([]);
    end
    
    function out = pathsForCode(this)
      % Paths that should be added to the Matlab PATH for this patch
      
      % Looks like this should be "under any toolbox/ or examples/ dir,
      % recursively, any dirs that contain *.m files or +* dirs, excluding the
      % +* dirs themselves".
      
      mfiles = findfiles('*.m', char(this.filesDir));
      codeDirs = cellfun(@(f){matpatch.Shed.codeDirForMfile(f)}, mfiles);
      out = unique(codeDirs);
    end
    
    function addToPath(this)
      % Makes sure all this' needed dirs are on the matlab path
      myCodeDirs = this.pathsForCode;
      currPath = strsplit(path, pathsep);
      toAdd = cellstr(setdiff(myCodeDirs, currPath));
      if isempty(toAdd)
        return
      end
      origWarn = warning;
      RAII.warning = onCleanup(@() warning(origWarn));
      warning off matlab:TODO:FIND:THIS:WARNING:ID:FOR:SHADOWING:FUNCTIONS
      addpath(toAdd{:}, '-begin');
      logger.debug('Added to Matlab path:\n%s', strjoin(toAdd, '\n'));
    end
    
    function removeFromPath(this)
      myCodeDirs = this.pathsForCode;
      currPath = strsplit(path, pathsep);
      toRemove = cellstr(intersect(myCodeDirs, currPath));
      rmpath(toRemove{:});
      logger.debug('Removed from Matlab path:\n%s', strjoin(toRemove, '\n'));
    end
    
    function out = allFiles(this)
      origCd = pwd;
      RAII.cd = onCleanup(@() cd(origCd));
      cd(this.filesDir);
      if ispc
        error('This is unsupported on Windows. Sorry')
      end
      files = findfiles('*', '.');
      files = regexprep(files, '^\.[/\\]', '');
      tfDir = cellfun(@isfolder, files);
      files(tfDir) = [];
      out = string(sort(files(:)));
    end
    
    function harvest(this)
      info = this.info;
      userInfo = matpatch.Shed.userConfigInfo;
      if ~isequal(matpatch.Shed.matlabVersion, info.MatlabVersion)
        mperror('Cannot harvest. This patch is against Matlab %s but you''re running %s.', ...
          info.MatlabVersion, matpatch.Shed.matlabVersion);
        return
      end
      % TODO: Detect whether a Unix-y diff is installed on Windows
      
      % We can't diff directly against the Matlab installation, because we want
      % to ignore non-existent files only on one side. So create a staging
      % directory.
      tempDir = [tempname '-MatPatchGardener-patch-' char(this.name)];
      matpatch.Shed.mkdir(tempDir);
      relFiles = this.allFiles;
      for rel = relFiles(:)'
        origFile = fullfile(matlabroot, rel);
        destInTempDir = fullfile(tempDir, rel);
        if isfile(origFile)
          matpatch.Shed.mkdir(fileparts(destInTempDir));
          copyfile(origFile, destInTempDir);
        end
      end
      
      origcd = pwd;
      RAII.origcd = onCleanup(@() cd(origcd));
      cd(this.filesDir);
      header = sprintf(strjoin({
        'Patch created by %s <%s> at %s'
        'Patch is against Matlab %s on %s'
        'Generated by MatPatchGardener (https://github.com/apjanke/MatPatchGardener)'
        ''
        ''
        }, '\n'), ...
        userInfo.Name, userInfo.Email, datestr(now), ...
        info.MatlabVersion, computer);
      matpatch.Shed.spew(this.patchFile, header);
      cmd = sprintf('LC_ALL=C diff -Nru "%s" . >> "%s"', ...
        tempDir, this.patchFile);
      system(cmd);
      
      matpatch.Shed.rmrf(tempDir);
      
      fprintf("\n");
      logger.info("Harvested patch %s.", this.name);
      logger.info("Created patch file at: %s", this.patchFile);
      fprintf("\n");
    end
  end
  
end
