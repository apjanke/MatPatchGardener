function mustBeScalar(x, label)
%MUSTBESCALAR Require that input is scalar
%
% mustBeScalar(x, label)
%
% Raises an error if the input x is not scalar, as determined by isscalar(x).
%
% label is an optional input that determines how the input will be described
% in error messages. If not supplied, `inputname(1)` is used, and if that is
% empty, it falls back to 'input'.

if nargin < 2; label = []; end

if ~isscalar(x)
  if isempty(label)
    label = inputname(1);
  end
  if isempty(label)
    label = 'input';
  end
  error('validoozy:validators:mustBeScalar', ...
    '%s must be scalar; got a %s', ...
    label, size2str(size(x)));
end
end
