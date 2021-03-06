# MatPatchGardener

MatPatchGardener is a tool for creating and maintaining patches to [Matlab](https://www.mathworks.com/products/matlab.html).
This is useful if you want to send suggested fixes when you submit Matlab bug reports to MathWorks.

It might also be useful if you want to do your own modifications to Matlab by "shadowing" its own definitions.
But do that at your own risk; it is an unsupported configuration.

## INTELLECTUAL PROPERTY WARNING

WARNING! Matlab is proprietary, commerical software. Its contents are the intellectual property of MathWorks. The patches you create are derived works of Matlab, and will also contain MathWorks' intellectual property. Do not give access to your patches to anyone unless you have verified that they have a currently active Matlab license!

## Requirements

On Windows, you need to install [GNU diffutils](http://gnuwin32.sourceforge.net/packages/diffutils.htm) or something else that gives you a Unix-y `diff` command.

MatPatchGardener requires the latest release of Matlab.
(There's not much point in producing patches for older releases.)
As of this writing, that's Matlab R2019b.

## Quick Start

```matlab

% Initialize the library

matpatch.wakeup

% Choose your garden

matpatch.Shed.activateGarden('/path/to/my/garden/dir');

% Let's work on datetime stuff

matpatch.dig('some-graphics-work')
mp_plant scatter scatter3
edit scatter3

% And then when you've made some changes to your local datetime copy:

matpatch.harvest

% Okay, let's work on something else

matpatch.dig('my-stats-stuff')
mp_plant mean

% What have we got going on now?

matpatch.lookaround
matpatch.listpatches
```

## Usage

You must call `matpatch.wakeup` to initialize the library every time you start a new Matlab session and want to use MatPatchGardener.
The easiest way to do this is to cd to the `Mcode/` directory under the MatPatchGardener installation and run it from there.

If this is your first time gardening, `matpatch.wakeup` will walk you through an interactive setup of your user info.

## Author

MatPatchGardner is written by [Andrew Janke](https://apjanke.net).

The project home page is <https://www.mathworks.com/products/matlab.html>. Bug reports and feature requests can be filed there.

### Acknowledgments

Also contains code from other authors:

Matt Tearle (2020). Recursively search for files (<https://www.mathworks.com/matlabcentral/fileexchange/57298-recursively-search-for-files>), MATLAB Central File Exchange. Retrieved January 23, 2020.
