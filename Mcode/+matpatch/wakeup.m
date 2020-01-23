function wakeup
% Get ready for gardening by initializing the MatPatchGardener library
%
% You have to wake up and get dressed before you do any gardening

repoDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
libDir = fullfile(repoDir, 'lib');

addpath(fullfile(repoDir, 'Mcode'));

% Set up our SLF4M dependency
slf4mDir = fullfile(libDir, 'matlab', 'SLF4M', 'SLF4M-HEAD');
addpath(fullfile(slf4mDir, 'Mcode'));
logger.initSLF4M;
logger.Log4jConfigurator.configureBasicConsoleLogging;
logger.Log4jConfigurator.setRootAppenderPattern(['%m' sprintf('\n')]); %#ok<SPRINTFN>

if isempty(matpatch.Shed.userConfigInfo)
  fprintf("\n");
  fprintf("Looks like it's your first time gardening. Let's get you set up!\n");
  fprintf("\n");
  matpatch.Shed.interactiveSetup;
end

logger.info("");
logger.info('You''re ready to garden!');

end