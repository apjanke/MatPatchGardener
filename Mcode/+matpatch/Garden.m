classdef Garden
  % A Garden is a collection of patches stored in a dir or repo
  
  properties (SetAccess = private)
    % The path to the root directory of the garden
    dir
  end
  
  properties (Dependent)
    patchesDir
  end
  
  methods
    
    function this = Garden(dir)
      if nargin == 0
        return
      end
      if ~isfolder(dir)
        error('Cannot find Garden: No such dir: %s', dir);
      end
      this.dir = dir;
    end
    
    function out = get.patchesDir(this)
      out = fullfile(this.dir, 'patches');
    end
    
    function out = newPatch(this, name)
      out = [];
      patchDir = fullfile(this.patchesDir, name);
      if isfolder(patchDir)
        logger.warn("A patch with name '%s' already exists! Not creating.", name);
        return
      end
      patch = matpatch.Patch(this, name, patchDir);
      patch.till;
      logger.info("Dug up new patch '%s' using Matlab %s", name, ...
        matpatch.Shed.matlabVersion);
      out = patch;
    end
    
    function out = getPatch(this, name)
      patchDir = fullfile(this.patchesDir, name);
      out = matpatch.Patch(this, name, patchDir);
    end
    
    function [out,details] = listPatches(this)
      names = matpatch.Shed.readdir(this.patchesDir);
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
    
  end
  
end