function varargout=bbInter(fName, varargin)
% Author: Jeong Joon Park 2014
%
% This set of functions deal with interaction between different sets of bounding boxes
% 
varargout = cell(1,max(1,nargout));
[varargout{:}] = feval(fName,varargin{:});
end

function track=trackerDetectorBbs(track_bbs,detect_bbs,thr,fr_num) 
%
% INPUT
%  track_bbs   - N x 7 matrix with 6th column as confidence level 0~1, 
%                7th column as starting frame number
%                6th column as confidence level between 0 and 1

	track_bbs=[track_bbs [1:size(track_bbs,1)]'];
	track_ig=track_bbs(track_bbs(:,5)==1,:);
	track_bbs=track_bbs(track_bbs(:,5)~=1,:);
	[~,ord]=sort(track_bbs(:,6),'descend'); track_bbs=track_bbs(ord,:);
	comp=bbGt('compOas',track_bbs,detect_bbs);
	for i=1:size(track_bbs,1)
		[shared,index]=max(comp(i,:));
		if (shared >= thr)
			track_bbs(i,1:4)=0.5*(track_bbs(i,1:4)+detect_bbs(index,1:4));
			track_bbs(i,7)=fr_num;
			comp(:,index)=0;
		end
	end
	track_bbs=[track_bbs;track_ig];
	[~,ord]=sort(track_bbs(:,8));
	track=track_bbs(ord,:);
	track=track(:,1:7);
end

