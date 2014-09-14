function varargin=trackerDetectorInter(fName, varargin)
varargout = cell(1,nargout);
[varargout{:}] = feval(action,varargin{:});
end