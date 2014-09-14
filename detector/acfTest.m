function [miss,roc,gt,dt] = acfTest( varargin )
% Test aggregate channel features object detector given ground truth.
%
% USAGE
%  [miss,roc,gt,dt] = acfTest( pTest )
%
% INPUTS
%  pTest    - parameters (struct or name/value pairs)
%   .detector - detector
%   .imgDir   - ['REQ'] dir containing test images
%   .gtDir    - ['REQ'] dir containing test ground truth
%   .pLoad    - [] params for bbGt>bbLoad for test data (see bbGt>bbLoad)
%   .thr      - [.5] threshold on overlap area for comparing two bbs
%   .mul      - [0] if true allow multiple matches to each gt
%   .reapply  - [0] if true re-apply detector even if bbs already computed
%   .ref      - [10.^(-2:.25:0)] reference points (see bbGt>compRoc)
%   .lims     - [3.1e-3 1e1 .05 1] plot axis limits
%   .show     - [0] optional figure number for display
%	.crop     - [0] optional figure to save ambiguous detection
%
% OUTPUTS
%  miss     - log-average miss rate computed at reference points
%  roc      - [nx3] n data points along roc of form [score fp tp]
%  gt       - [mx5] ground truth results [x y w h match] (see bbGt>evalRes)
%  dt       - [nx6] detect results [x y w h score match] (see bbGt>evalRes)
%
% EXAMPLE
%
% See also acfTrain, acfDetect, acfDemoInria, bbGt
%
% Piotr's Image&Video Toolbox      Version 3.22
% Copyright 2013 Piotr Dollar & Ron Appel.  [pdollar-at-caltech.edu]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the Simplified BSD License [see external/bsd.txt]

% get parameters
dfs={ 'detector','REQ','name','REQ', 'imgDir','REQ', 'gtDir','REQ', 'pLoad',[], ...
  'thr',.5,'mul',0, 'reapply',0, 'ref',10.^(-2:.25:0), ...
  'lims',[3.1e-3 1e1 .05 1], 'show',0, 'crop', 0};
[detector,name,imgDir,gtDir,pLoad,thr,mul,reapply,ref,lims,show,crop] = ...
  getPrmDflt(varargin,dfs,1);

crop
show
imgDir
gtDir

% run detector on directory of images
bbsNm=[name 'Dets.txt'];
if(reapply && exist(bbsNm,'file')), delete(bbsNm); end
if(reapply || ~exist(bbsNm,'file'))

  imgNms = bbGt('getFiles',{imgDir});
  bbs=acfDetect( imgNms, detector, bbsNm );
  bbs(1,:)
  bbsNm(1,:)
end

if(crop)
	name_index=1;
	ambig=bbs(bbs(:,6)<10,:);
	ambig_img=ambig(:,1);
	[~,index]=unique(ambig_img,'first');
	ambig_img=ambig_img(sort(index));


	for i=1:numel(ambig_img)
		image_num=ambig_img(i);
		I=imread(imgNms{image_num});
		bb=ambig(ambig(:,1)==image_num,:);
		bb=bb(:,2:end);
		patches= bbApply('crop',I,bb,[0],[]);
			for j=1:numel(patches)
			imwrite(patches{j},[num2str(name_index) '.png']);
		end
		name_index=name_index+1;
	end

	system('mv *.png data/inria/cropped');
	system('cd data/inria/cropped && zip cropped.zip *.png');
end
%}

if(show==1)
	% run evaluation using bbGt
	display('aaaaaaa')
	[gt,dt] = bbGt('loadAll',gtDir,bbsNm,pLoad);
	bbsNm
	[gt,dt] = bbGt('evalRes',gt,dt,thr,mul);
	display('bbbbbbb')
	figure(2);
	[recall,precision,score,miss] = bbGt('compRoc',gt,dt,0,ref);
	plot(precision,recall);axis([0 1 0 1]);
	xlabel('precision'); ylabel('recall');
	miss=exp(mean(log(max(1e-10,1-miss)))); roc=[score recall precision];

	end
end