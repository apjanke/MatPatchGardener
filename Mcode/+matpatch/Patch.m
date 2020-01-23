classdef Patch
  % A Patch is a set of changes to Matlab, stored in a directory
  
  properties (SetAccess = private)
    % Parent garden
    garden
    % Path to the patch dir
    dir
    filesDir
    infoFile
  end
  
  
  methods
    
    function this = Patch(garden, dir)
      % Create a new object looking at a patch directory
      %
      % obj = Patch(garden, dir)
      %
      % Dir is the path to the patch directory. It does not have to exist; this
      % object may be used to create the directory with the TILL method.
      if nargin == 0
        return
      end
      mustBeA(garden, 'matpatch.Garden');
      this.garden = garden;
      this.dir = string(dir);
      this.filesDir = fullfile(this.dir, 'files');
      this.infoFile = fullfile(this.dir, 'info.json');
    end
    

    function out = info(this)
      out = jsondecode(fileread(this.infoFile));
    end
    
    function till(this)
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
      % Plant copies of Matlab's files in this patch, shadowing the originals
      things = string(things);
      things = things(:)';
      
      info = this.info;
      if ~isequal(info.MatlabVersion, matpatch.Shed.matlabVersion)
        matpatch.error(['Cannot plant: this patch is against Matlab %s, but '...
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
            matpatch.error("I don't know what to do with plain file paths: %s", thing);
          else
            matpatch.error("Could not find thing: %s", thing);
          end
          return
        else
          if startsWith(w, matlabroot)
            relFiles(iThing) = w(numel(matlabroot)+2:end);
          else
            matpatch.error("File for thing '%s' is not under matlabroot.", thing);
            return
          end
        end
        
        % See if we need to grab private directories, too
        privDirs = string.empty;
        for f = relFiles
          parentDir = fileparts(f);
          privDir = fullfile(parentDir, 'private');
          if isfolder(privDir)
            privDirs(end+1) = privDir; %#ok<AGROW>
          end
        end
        privDirs = unique(privDir);
        
        % Okay, all things resolved to files
        for i = 1:numel(relFiles)
          f = relFiles(i);
          source = fullfile(matlabroot, f);
          dest = fullfile(this.filesDir, f);
          matpatch.Shed.mkdir(fileparts(dest));
          copyfile(source, dest);
          logger.info("Planted %s at %s", things(i), f);
        end
        if ~isempty(privDirs)
          logger.info("Grabbing %d private/ dirs, too", numel(privDirs));
        end
        for i = 1:numel(privDirs)
          relDir = strrep(privDirs(i), matlabroot, "");
          dest = fullfile(this.filesDir, relDir);
          matpatch.Shed.cpr(privDirs(i), dest);
          logger.info("Planted %s at %s", relDir, dest);
        end
      end
    end
    
  end
  
end