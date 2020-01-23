classdef Shed
  % The Shed contains all the tools for maintaining a patch garden
  
  properties (Constant)
    % The default garden path to use for new users
    DefaultDefaultGardenPath = "~/MatPatchGarden"
  end
  
  methods (Static)
    
    function [out, details] = readdir(pth)
      % List the directory entries under a given dir
      %
      % Does not include . and .. in the output.
      %
      % Returns a string vector.
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
        [status,out] = system(['cp -R "' char(src) '" "' char(dest) '"']);
      else
        [status,out] = system(['xcopy "' char(src) '" "' char(dest) '\" /E/H']);
      end
      if status ~= 0
        error("Failed copying '%s' to '%s': %s", src, dest, out);
      end
    end
    
    function rmrf(target)
      % Recursively, forcibly remove files
      if ispc
        cmd = sprintf('del /S /F /Q "%s"', target);
      else
        cmd = sprintf('rm -rf "%s"', target);
      end
      [status, output] = system(cmd);
      if status ~= 0
        logger.warn("Failed deleting %s: %s", target, output);
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
      RAII.fid = onCleanup(@() fclose(fid));
      fprintf(fid, '%s', txt);
    end
    
    function out = getappdata(name)
      % Gets a MatPatchGardener appdata value
      s = getappdata(0, 'matpatchgardener_state');
      if isempty(s) || ~isfield(s, name)
        % TODO: Should non-found name in existing struct be an error?
        out = [];
        return
      end
      out = s.(name);
    end
    
    function setappdata(name, val)
      % Sets a MatPatchGardener appdata value
      s = getappdata(0, 'matpatchgardener_state');
      if isempty(s)
        s = struct;
      end
      s.(name) = val;
      setappdata(0, 'matpatchgardener_state', s);
    end
    
    function setDefaultGarden(dir)
      % Persistently set the default garden that you get when you wakeup
      %
      % matpatch.Shed.setDefaultGarden(pathToGardenDir)
      s = matpatch.Shed.userConfigInfo;
      s.DefaultGarden = dir;
      matpatch.Shed.userConfigInfo(s);
    end
    
    function out = activeGarden(dir)
      % Get or set the active garden for this process
      %
      % out = matpatch.Shed.activeGarden
      % matpatch.Shed.activeGarden(pathToGardenDir)
      %
      % Returns a matpatch.Garden object or [].
      if nargin == 0
        currPath = matpatch.Shed.getappdata('garden_path');
        if isempty(currPath)
          out = [];
          return;
        end
        out = matpatch.Garden(currPath);
      else
        if isstring(dir)
          mustBeScalar(dir)
          dir = char(dir);
        end
        mustBeCharvec(dir);
        if ~isfolder(dir)
          logger.warn('Setting Garden to non-existent dir: %s', dir);
        end
        oldVal = matpatch.Shed.activeGarden;
        if ~isequal(dir, oldVal)
          matpatch.Shed.setappdata('garden_path', dir);
          % Clear the active patch when switching gardens; it won't be
          % applicable even if it has the same name.
          matpatch.Shed.activePatchName([]);
        end
      end
    end
    
    function out = activePatchName(name)
      % Name of the current active patch
      %
      % Returns a string or charvec, or [] if there is no active patch.
      if nargin == 0
        out = matpatch.Shed.getappdata('active_patch');
      else
        matpatch.Shed.setappdata('active_patch', name);
      end
    end
    
    function out = activePatch()
      % Get the active patch in the active garden
      %
      % Returns a Patch object, or [] if there is no active patch.
      garden = matpatch.Shed.activeGarden;
      if isempty(garden)
        out = [];
        return
      end
      if isempty(matpatch.Shed.activePatchName)
        out = [];
        return
      end
      out = garden.getPatch(matpatch.Shed.activePatchName);
    end
    
    function activatePatch(name)
      % Activate the named patch in the current active garden
      garden = matpatch.Shed.activeGarden;
      if isempty(garden)
        mperror("No active garden.");
        return;
      end
      newPatch = garden.getPatch(name);
      if isempty(newPatch)
        mperror("No such patch: %s", name);
        return;
      end
      oldPatch = matpatch.Shed.activePatch;
      if ~isempty(oldPatch)
        oldPatch.deactivate;
      end
      newPatch.activate;
      matpatch.Shed.activePatchName(name);
    end
    
    function out = configDir()
      % Path to the user's MatPatchGardener config directory
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
      % Path to the user's MatPatchGardener config file
      out = fullfile(matpatch.Shed.configDir, 'gardener.json');
    end
    
    function out = userConfigInfo(newInfo)
      % Get or set the persistent user config info
      %
      % out = matpatch.Shed.userConfigInfo()
      % matpatch.Shed.userConfigInfo(newInfo)
      %
      % The setter form completely overwrites the user config info, so make sure
      % you read it first and then incrementally add new entries to it!
      configFile = matpatch.Shed.userConfigFile;
      if nargin == 0
        if ~isfile(configFile)
          out = struct;
          return
        end
        out = jsondecode(fileread(configFile));
      else
        if ~isstruct(newInfo)
          error('User config info must be a struct; got a %s', class(newInfo));
        end
        matpatch.Shed.spew(configFile, jsonencode(newInfo));
      end
    end
    
    function interactiveSetup
      % Set up your shed for the first time with an interactive dialog
      %
      % Runs an interactive dialog getting user information.
      %
      % This initializes the user config file in your config directory.
      
      % TODO: Use old values as defaults if run while a config file exists
      s.Name = input("Your name: ", "s");
      s.Email = input("Your email address: ", "s");
      s.GitHubUser = input("Your GitHub username (optional): ", "s");
      % TODO: On Windows, default garden path should go under ~/Documents,
      % not just ~.
      dfltGarden = matpatch.Shed.DefaultDefaultGardenPath;
      gardDir = input(sprintf("Default garden path [%s]: ", dfltGarden), "s");
      fprintf("\n");
      if isempty(gardDir)
        gardDir = char(dfltGarden);
      end
      if gardDir(1) == '~'
        gardDir = fullfile(matpatch.Shed.userHomeDir, gardDir(2:end));
      end
      try
        garden = matpatch.Garden(gardDir);
        if ~garden.isInitializedOnDisk
          garden.initializeOnDisk;
          logger.info("Created your garden at %s.", gardDir);
        end
      catch err
        logger.warn("Warning: Failed creating garden dir at %s: %s", gardDir, err.message);
      end
      s.DefaultGarden = gardDir;
      matpatch.Shed.userConfigInfo(s);
      fprintf("Wrote your gardener info to: %s\n", matpatch.Shed.userConfigFile);
      logger.debug("Wrote your gardener info to: %s", matpatch.Shed.userConfigFile);
      if ~isempty(gardDir)
        matpatch.Shed.activeGarden(gardDir);
      end
    end
    
    function out = userHomeDir
      % The user's home dir, as defined by this OS's conventions
      if ispc
        out = getenv('USERPROFILE');
      else
        out = getenv('HOME');
      end
    end
    
    function out = codeDirForMfile(mfilePath)
      % For a given mfile, get the dir that should be on the path to expose it
      %
      % This accounts for +pkg namespace structure.
      immedParent = fileparts(mfilePath);
      els = strsplit(immedParent, filesep);
      while els{end}(1) == '+' || els{end}(1) == '@' || isequal(els{end}, 'private')
        els(end) = [];
      end
      out = strjoin(els, filesep);
    end
    
    function out = findfiles(pattern, basedir)
      % Recursively find files matching a pattern
      out = findfiles(pattern, basedir);
    end
    
  end
  
end