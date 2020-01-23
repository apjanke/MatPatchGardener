classdef Garden
  % A Garden is a collection of patches stored in a dir or repo
  
  properties (SetAccess = private)
    % The path to the root directory of the garden
    dir
  end
  
  properties (Dependent)
    % The patches directory under this garden
    patchesDir
  end
  
  methods
    
    function this = Garden(dir)
      % Construct a new object
      if nargin == 0
        return
      end
      this.dir = dir;
    end
    
    function out = get.patchesDir(this)
      out = fullfile(this.dir, 'patches');
    end
    
    function out = newPatch(this, name)
      % Create a new patch in this garden
      out = [];
      patchDir = fullfile(this.patchesDir, name);
      if isfolder(patchDir)
        logger.warn("A patch with name '%s' already exists! Not creating.", name);
        return
      end
      patch = matpatch.Patch(this, name, patchDir);
      patch.dig;
      logger.info("Dug up new patch '%s' using Matlab %s", name, ...
        matpatch.Shed.matlabVersion);
      out = patch;
    end
    
    function out = getPatch(this, name)
      % Get an existing patch in this garden
      patchDir = fullfile(this.patchesDir, name);
      out = matpatch.Patch(this, name, patchDir);
    end
    
    function [out,details] = listPatches(this)
      % List all the patches in this garden
      names = matpatch.Shed.readdir(this.patchesDir);
      % TODO: Add bogus Windows files
      % TODO: Ignore all files starting with dot
      names = setdiff(names, {'.DS_Store'});
      names = names(:);
      vers = repmat(string(missing), size(names));
      for i = 1:numel(names)
        p = this.getPatch(names(i));
        info = p.info;
        vers(i) = info.MatlabVersion;
      end
      details = table(names, vers, 'VariableNames', {'Name','MatlabVersion'});
      out = names';
      if nargout == 0
        disp(details)
        clear out
      end
    end
    
    function initializeOnDisk(this)
      % Initialize the directory structure for this garden
      matpatch.Shed.mkdir(this.dir);
      matpatch.Shed.mkdir(this.patchesDir);
    end
    
    function out = isInitializedOnDisk(this)
      % Whether the directory structure for this garden is initialized
      out = isfolder(this.dir) && isfolder(this.patchesDir);
    end
    
  end
  
end