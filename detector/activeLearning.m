% Author: Jeong Joon Park 2014
% active learning scheme simulation
% used variables

base='/home/jj/vision/caltech-whole';
im_paths=subdir('get_all_paths',base,{'set*','*V*'},{});
anno_im=subdir('get_all_paths',base,{'set*','*V*','*anno_im*'},{});
anno_gt=subdir('get_all_paths',base,{'set*','*V*','*anno_gt*'},{});
track_im=subdir('get_all_paths',base,{'set*','*V*','*track_im*'},{});
track_gt=subdir('get_all_paths',base,{'set*','*V*','*track_gt*'},{});
base='/home/jj/vision/caltech-whole/annotations';
anno_paths=subdir('get_all_paths',base,{'set*','*V*'},{});

paths_num=11;

r_thresh=0.3; % target tracker and detector match ratio
file_names=alQueries('mulGetFiles',{im_paths(paths_num),anno_paths(paths_num)});
im_names=file_names(1,:); anno_names=file_names(2,:);

pLoad={'lbls',{'person'},'ilbls',{'people'}};
detections=acfDetect(im_names,detector);


im_index=1;
track_base_index=im_index;
track_base_bbs=[];
count=1;
num_queried=0;

while(im_index<=numel(im_names))
  im_index
  if(rem(im_index,30)==1)
    disp('rem==1')
    [~,track_base_bbs]=bbGt('bbLoad',anno_names{im_index},pLoad);
    track_base_index=im_index; num_queried=num_queried+1
  else
  	track_bbs=alQueries('tracking_queries',im_paths{paths_num},...
  		track_base_index,track_base_bbs,im_index);
  	track_size=size(track_bbs,1); track_bbs(track_bbs(:,5)==-1,:)=[];
  	[match_t,match_d]=bbGt('evalRes',track_bbs(:,1:5),detections{im_index},0.5,1)
    no_match=sum(match_t(:,5)==0); ratio=1-(no_match/track_size); % match ratio
    if(ratio>r_thresh) % if match rate is above threshold
      disp('good!');
      yes_match=match_t(match_t(:,5)~=0,:);
      alQueries('createGtFile',track_gt{paths_num},... % store the tracker record as gt
        [im_names{im_index}(end-9:end-3) 'txt'],yes_match,{'person','people'},[1,-1]); 
    else
      [~,track_base_bbs]=bbGt('bbLoad',anno_names{im_index},pLoad);
      track_base_index=im_index; num_queried=num_queried+1
    end


  end
  im_index=im_index+1;
end
