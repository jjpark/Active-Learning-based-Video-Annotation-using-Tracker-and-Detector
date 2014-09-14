function [detections] = tracking_queries(dataDir, img_start, gt0, img_queried)
% Tracking_query function Jeong Joon Park 2014
% 
% USAGE
%   [detections] = tracking_queries(dataDir, img_start, gt0, img_queried)
% 
% INPUTS
%  dataDir     - data directory of images to be tracked
%  img_start   - integer value index of the first image to be tracked
%  gt0         - ground truth (bounding boxes) for the first image: 4xN (x,y,width,height)
%  img_queried - integer value index of the image that will be tracked from the first image
%
% OUTPUTS
%  detections  - 5xN detection results. Fifth row is confidence score from the queried image; -1 if lost.
%
% See also kernelTracker.m
%
  
  assert(img_queried>img_start, 'wrong image indexes');
  imgNms=bbGt('getFiles',{[dataDir]}, img_start, img_queried);

  gt_num = size(gt0,1);
  prm.dispFlag=0;
  detections=zeros(gt_num,5);

  for i=1:numel(imgNms)
    I(:,:,:,i)=imread(imgNms{i});
  end

  for i=1:gt_num % for each starting ground truth bounding box
    prm.rctS=gt0(i,:);
    [allRct, allSim, allIc] = kernelTracker( [I], [prm] );
    if(numel(allSim)==numel(imgNms))
      detections(i,:)=[allRct(end,:),allSim(end)];
    else
      detections(i,:)=[-1,-1,-1,-1,-1];
    end
  end

end