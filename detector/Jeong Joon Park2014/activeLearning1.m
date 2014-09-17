function result=activeLearning1(detector,dataDir,gtDir,gtSavDir,negSavDir,im_start,threshold)
% This function is a platform that trains a pedestrian detector using 
% Active Learning along with tracking
%
% 
%
imgNms=bbGt('getFiles',{[dataDir]});
im_index=im_start;
track_base_index=im_index;
count=1;
track_base_bbs=[];
num_queried=0;
while(im_index<=numel(imgNms))
  im_index
  detect_bbs=alQueries('detectorQueries',detector,dataDir,im_index);

  if(rem(count,30)~=1);
    track_bbs=alQueries('tracking_queries',dataDir,track_base_index,track_base_bbs(:,1:4),im_index);
    track_bbs(:,5)=0; %ignore flags to 0
    [match_t,match_d]=alQueries('compareBbs',track_bbs,detect_bbs,0.5,0)
    if(sum(match_t(:,5))<threshold*size(match_t,1))
      gt=alQueries('query_gt','dataDir',gtDir,'index',im_index)
      num_queried=num_queried+1
      [match1,match_d]=alQueries('compareBbs',gt,detect_bbs,0.5,0);
      false_pos=match_d(match_d(:,5)==0,:);
      track_base_index=im_index;
      track_base_bbs=gt;

    else
      % TODO change to match_t where flag is 1
      result=alQueries('createGtFile',gtSavDir,['gt' num2str(im_index)],track_bbs); 
    end

    false_pos=match_d(match_d(:,5)==0,:);

  else; % get gt every thirty frames
    gt=alQueries('query_gt','dataDir',gtDir,'index',im_index);
    num_queried=num_queried+1
    [match1,match_d]=alQueries('compareBbs',gt,detect_bbs,0.5,0);
    false_pos=match_d(match_d(:,5)==0,:);

    track_base_index=im_index;
    track_base_bbs=gt;
  end;
  result=alQueries('cropNegs',imread(imgNms{im_index}),false_pos,negSavDir);   
  im_index=im_index+1;
  count=count+1;
end

end