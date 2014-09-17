function varargout=manageTracker(action,varargin)
  varargout=cell(1,max(1,nargout));
  varargout{:}=feval(action,varargin{:});
end

function tracker=updateTWithGt(tfname,I,tracker,gt,prmT)
%
% tfname is name of the update tracker function to be used. e.g. updateCTTracker
%
% EXAMPLE
%   tracker=manageTracker('updateTWithGt','updateCTTracker',I,tracker,bbs,prmTrack)
  tracker=[];
  num=size(gt,1)
  for i=1:num
    tracker(i).tracker=feval(tfname,I,[],gt(i,1:4),prmT);
    tracker(i).id=gt(i,5);
  end
end