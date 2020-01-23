classdef Shed
  % The Shed contains all the tools for maintaining a patch garden
  
  methods (Static)
  
    function [out, details] = readdir(pth)
      if ~isfolder(pth)
        error('Path is not a folder: %s', pth);
      end
      d = dir(pth);
      name = {d.name};
      tfIgnore = ismember(name, ["." ".."]);
      d(tfIgnore) = [];
      out = string({d.name});
      details = d;
    end
    
    function mkdir(dir)
      % Make a dir, including parents, only if it does not exist
      if isfolder(dir)
        return
      end
      [ok,msg] = mkdir(dir);
      if ~ok
        error("Failed creating directory '%s': %s", msg);
      end
    end
    
    function cpr(src, dest)
      % Recursive copy of files and dirs
      if isunix
        [status,out] = system(['cp -R "' char(src) '" "' char(dest)]);
      else
        [status,out] = system(['xcopy "' char(src) '" "' char(dest) '\ /E/H']);
      end
      if status ~= 0
        error("Failed copying '%s' to '%s': %s", src, dest, out);
      end
    end
    
    function [release, details] = matlabVersion()
      % The Matlab version for this Matlab session
      v = ver('MATLAB');
      v.Release = regexprep(v.Release, '[()]', '');
      release = v.Release;
      details = v;
    end
    
    function spew(file, txt)
      % Write text to a file, replacing existing contents
      matpatch.Shed.mkdir(fileparts(file));
      [fid,msg] = fopen(file, 'w');
      if fid < 1
        error("Failed opening file '%s' for writing: %s", file, msg);
      end
      RAII.fid = @() fclose(fid); %#ok<STRNU>
      fprintf(fid, '%s', txt);
    end
    
    function out = getappdata(name)
      s = getappdata(0, 'matpatchgardener_state');
      if isempty(s) || ~isfield(s, name)
        % TODO: Should non-found name in existing struct be an error?
        out = [];
        return
      end
      out = s.(name);
    end
    
    function setappdata(name, val)
      s = getappdata(0, 'matpatchgardener_state');
      if isempty(s)
        s = struct;
      end
      s.(name) = val;
      setappdata(0, 'matpatchgardener_state', s);
    end
    
    function out = currentGarden(dir)
      if nargin == 0
        currPath = matpatch.Shed.getappdata('garden_path');
        if isempty(currPath)
          error('No current garden is set!');
        end
        out = matpatch.Garden(currPath);
      else
        mustBeCharvec(dir);
        if ~isfolder(dir)
          logger.warn('Setting Garden to non-existent dir: %s', dir);
        end
        oldVal = matpatch.Shed.currentGarden;
        if ~isequal(dir, oldVal)
          matpatch.Shed.setappdata('garden_path', dir);
          % Clear the active patch when switching gardens; it won't be
          % applicable even if it has the same name.
          matpatch.Shed.activePatch([]);
        end
      end
    end
    
    function out = activePatch(name)
      if nargin == 0
        out = matpatch.Shed.getappdata('active_patch');
      else
        matpatch.Shed.setappdata('active_patch', name);
      end
    end
    
    function out = configDir()
      if ispc
        configDir = getenv('APPDATA');
      else
        configDir = getenv('XDG_CONFIG_HOME');
        if isempty(configDir)
          configDir = fullfile(getenv('HOME'), '.config');
        end
      end
      out = fullfile(configDir, 'MatPatchGardener');
      matpatch.Shed.mkdir(out);
    end
    
    function out = userConfigFile()
      out = fullfile(matpatch.Shed.configDir, 'gardener.json');
    end
    
    function out = userConfigInfo()
      file = matpatch.Shed.userConfigFile;
      if ~isfile(file)
        out = [];
        return
      end
      out = jsondecode(fileread(file));
    end
    
    function interactiveSetup
      % Set up your shed for the first time with an interactive dialog
      %
      % Runs an interactive dialog getting user information.
      %
      % This initializes the user config file in your config directory.
      
      % TODO: Use old values as defaults if run while a config file exists
      s.name = input("Your name: ", "s");
      s.email = input("Your email address: ", "s");
      s.ghuser = input("Your GitHub username (optional): ", "s");
      matpatch.Shed.spew(matpatch.Shed.userConfigFile, jsonencode(s));
      fprintf("\nWrote your gardener info to: %s\n", matpatch.Shed.userConfigFile);
      logger.debug("Wrote your gardener info to: %s", matpatch.Shed.userConfigFile);
    end
    
  end
  
end