function [precision,recall]=track3frs(imDir,gtDir,targetDir,gtRate,numTrFrs)
% Author: Jeong Joon Park 2014
%
% imDir and gtDir are cell array of directories

  numDir=numel(imDir);
  % for each directory
  for i=1:numDir
    % get image and annotation names
    files=bbGt('getFiles',{imDir{i},gtDir{i}});
    % set annotation load parameters
    pLoad={'lbls',{'person'},'ilbls',{'people'}};



      % iterate through each images 
      for j=1:size(files,2)

        j
        % for each keyframe
        if(rem(j,gtRate)==1)
          before=(j-3>0);
          after=(j+3<=size(files,2));

          % load ground truth
          clear beforeI; clear afterI;
          [~,bbs]=bbGt('bbLoad',files{2,j},pLoad);

          for k=0:numTrFrs
            if(before)
              beforeI(:,:,:,k+1)=imread(files{1,j-k});
              name=extractName(files{2,j-k},'txt');
              bbB=alQueries('kernel_tracking_queries',beforeI,bbs);
              alQueries('createGtFile',targetDir,name,bbB,...
                  {'person','people'},[0,1]);
            end

            if(after)
              afterI(:,:,:,k+1)=imread(files{1,j+k});
              name=extractName(files{2,j+k},'txt');
              bbA=alQueries('kernel_tracking_queries',afterI,bbs);
              alQueries('createGtFile',targetDir,name,bbA,...
                  {'person','people'},[0,1]);
            end

          end

        else
          continue;
        end
      end
  end
  precision=1;recall=1;
end

function name=extractName(f,extension) 
    st=strfind(f,'/'); st=st(end); en=strfind(f,'.'); en=en(end);
    name=[f(st+1:en-1) '.' extension];
end