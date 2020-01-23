function error(fmt, varargin)
% Note that an error has occurred, but don't raise an exception

fprintf(['Error: ' char(fmt) '\n'], varargin{:});

end