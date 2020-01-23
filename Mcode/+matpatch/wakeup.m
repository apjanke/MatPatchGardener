function wakeup
% Get ready for gardening by initializing the MatPatchGardener library
%
% You have to wake up and get dressed before you do any gardening.
%
% This loads the MatPatchGardener library, and if you're using MatPatchGardener
% for the first time, will run an interactive setup utility to configure your
% user information.

repoDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
libDir = fullfile(repoDir, 'lib');

addpath(fullfile(repoDir, 'Mcode'));

% Set up our SLF4M dependency
slf4mDir = fullfile(libDir, 'matlab', 'SLF4M', 'SLF4M-HEAD');
addpath(fullfile(slf4mDir, 'Mcode'));
logger.initSLF4M;
logger.Log4jConfigurator.configureBasicConsoleLogging;
logger.Log4jConfigurator.setRootAppenderPattern(['%m' sprintf('\n')]); %#ok<SPRINTFN>

if isempty(fieldnames(matpatch.Shed.userConfigInfo))
  fprintf("\n");
  fprintf("Looks like it's your first time gardening. Let's get you set up!\n");
  fprintf("\n");
  matpatch.Shed.interactiveSetup;
end

userInfo = matpatch.Shed.userConfigInfo;
if isfield(userInfo, 'DefaultGarden')
  matpatch.Shed.activeGarden(userInfo.DefaultGarden);
end

fprintf("\n");
logger.info('You''re ready to garden!');
fprintf("\n");

end