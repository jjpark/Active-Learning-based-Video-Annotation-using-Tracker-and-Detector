function varargout = alQueries(action, varargin)
% Functions for making and receiving active learning queries Jeong Joon Park 2014
%
% Format output = alQueries('action', 'varargin');
% The list of functions and help for each is given below.
%
% Tracking result of bbs from image one to another
%   detections = alQueries('tracking_queries',dataDir, img_start, gt0, img_queried);
% Load detector
%   detector = alQueries('loadDet',name);
% Detecting result of an image
%   detections = alQueries('detectorQueries', detector, varargin);
% Create ground truth text file
%   alQueries('createGtFile',dataDir,name,bbs, varargin);
% Crop negative windows and send it to a folder
%   alQueries('cropNegs', I, bbs, dataDir);
% Query ground truth bbs of an image
%   bbs = alQueries('query_gt', varargin);
% Compare two bounding boxes 
%   equal = alQueries('compareBbs',bbs1, bbs2, thr);
%

varargout = cell(1,max(1,nargout));
[varargout{:}] = feval(action,varargin{:});
end

function [detections] = tracking_queries(dataDir, img_start, gt0, img_queried)
% 
% USAGE
%   [detections] = alQueries('tracking_queries', dataDir, img_start, gt0, img_queried)
% 
% INPUTS
%  dataDir     - data directory of images to be tracked
%  img_start   - integer value index of the first image to be tracked
%  gt0         - ground truth (bounding boxes) for the first image: 5xN (x,y,width,height,ignore)
%  img_queried - integer value index of the image that will be tracked from the first image
%
% OUTPUTS
%  detections  - 6xN detection results. 
%    Fifth row is 0 when not ignore, 1 if ignore flag is on 
%    Sixth row is confidence score; -1 if lost
%
% See also kernelTracker.m
%
  
  assert(img_queried>img_start, 'wrong image indexes');

  imgNms=bbGt('getFiles',{[dataDir]}, img_start, img_queried);
  num_img=numel(imgNms);

  gt_num = size(gt0,1);
  prm.dispFlag=0;
  detections=zeros(gt_num,6);

  for i=1:numel(imgNms)
    I(:,:,:,i)=imread(imgNms{i});
  end

  for i=1:gt_num % for each starting ground truth bounding box
    prm.rctS=gt0(i,1:4);
    [allRct, allSim, allIc] = kernelTracker( [I], [prm] );
    if(numel(allSim)==num_img)
      detections(i,:)=[allRct(end,:),gt0(i,5),allSim(end)];
    else
      detections(i,:)=[-1,-1,-1,-1,-1,-1];
    end
  end

end

function [detections] = kernel_tracking_queries(I, gt0)
% 
% USAGE
%   [detections] = alQueries('tracking_queries', dataDir, img_start, gt0, img_queried)
% 
% INPUTS
%  I           - height x width x 3 x N array of images
%  gt0         - ground truth (bounding boxes) for the first image: 5xN (x,y,width,height,ignore)
%
% OUTPUTS
%  detections  - 6xN detection results of the last image. 
%    Fifth row is 0 when not ignore, 1 if ignore flag is on 
%    Sixth row is confidence score;
%
% See also kernelTracker.m
%
  
  gt_num = size(gt0,1);
  prm.dispFlag=0;
  prm.simThr=0.3;
  detections=[];

  num_img=size(I,4);

  for i=1:gt_num % for each starting ground truth bounding box
    prm.rctS=gt0(i,1:4);
    [allRct, allSim, allIc] = kernelTracker( [I], [prm] );
    if(numel(allSim)==num_img)
      detections(end+1,:)=[allRct(end,:),gt0(i,5),allSim(end)];
    end
  end


end


function detector=loadDet(name, varargin)
% load detector of given name
%
% USAGE 
%   detector = alQueries('loadDet',name);
%
% INPUTS
%   name     - path name to the detector
%
% OUTPUTS
%   detector - the loaded detector of the name
%
  assert(0~=exist([name 'Detector.mat']),'Detector does not exist');
  detector = load([name 'Detector.mat']);
  detector = detector.detector;
end

function detections=detectorQueries(detector, varargin)
% Detector results for an image
% 
% USAGE 
%   detections=alQueries('detectorQueries', detector, path);
%   detections=alQueries('detectorQueries', detector, dataDir, index);
%   detections=alQueries('detectorQueries', detector, dataDir, name);
%
% INPUTS
%   path       - absolute path of the target image
%   dataDir    - directory that contains the target image
%   index      - index of the target image in the directory
%   name       - name of the target image in directory
%
% OUTPUTS
%   detections - 5xN detection results. Fifth row is confidence score
%
  assert(nargin>1, 'not enough argument');
  if (nargin==2)
    I=imread(varargin{1});
  else
    if(isnumeric(varargin{2})); direc=bbGt('getFiles',{[varargin{1}]},varargin{2},varargin{2});
    direc=direc{1};
    else; direc=[varargin{1} '/' varargin{2}]; end;
    I=imread(direc);
  end

  detections=acfDetect(I,detector);
end

function result=createGtFile(dataDir,name,bbs,varargin)
%
% USAGE
%   result=alQueries('createGtFile',dataDir,name,bbs,label);
% 
% INPUTS
%   dataDir     - data directory to create a gt file
%   name        - name of the gt file
%   bbs         - n x 4 bounding boxes
%   varargin
%     label       - labels of the annotation, e.g. {'person'}: default is person
%     label_rules - fifth row of bbs corresponds to label. e.g. [1,-1]
% 
%   For example if label is {'person','people'} and label_rules is ['1','-1'],
%   Then, fifth row of 1 is labeld 'person' while -1 is labeled 'people'
%   
%
  curr=pwd;
  cd(dataDir);
  assert(nargin<=5,'too many arguments');
  label=varargin{1};
  label_rules=varargin{2};

  numObj = size(bbs,1);
  objs = bbGt('create',numObj);
  for i=1:numObj
    objs(i).bb=bbs(i,1:4);
    if(nargin==5); 
      [ind]=find(label_rules==bbs(i,5));
      lbl=label{ind};
      objs(i).lbl=lbl; 
    else; objs(i).lbl='person'; end;
  end
  bbGt('bbSave',objs,name);
  %[s,mess,messid]=movefile(name,dataDir);
  %assert(0~=exist([dataDir '/' name]));
  result=1;
  cd(curr);
end

function result=cropNegs(I,bbs,dataDir,varargin)
% This function crop negative sample and send it to a directory
%
% The cropped images will be used as a negative sasmple for training
% A bootstrapping could be done in active learning style, getting negative samples
% from false positives. 
% The false positives of an image I is bbs, and this function crops the samples and send them
% to dataDir with a naming convention specified. 
% If not specified, the name of the cropped samples will be ['neg' num2str(index)]
% 
% USAGE
% result=alQueries('cropNegs',I,bbs,dataDir,'neg');
%
% INPUTS
%  I        - Image to be cropped
%  bbs      - Bounding boxes for negative cropping 
%  dataDir  - Directory path to send cropped images to
%  varargin - name Convention for the file, default: 'neg'. 
%
  assert(nargin<5,'too many arguments');
  if(nargin==3); nameConvention='neg'; elseif(nargin==4); nameConvention=varargin{1}; end;

  patches=bbApply('crop',I,bbs,[0],[]);

  index=size(dir([dataDir '/*' nameConvention '*.jpg']),1)+1;
  curr=pwd;
  cd(dataDir);
  for i=1:numel(patches)
    imwrite(patches{i},[nameConvention num2str(index) '.jpg']);
    index=index+1;
  end
  cd(curr);

  result=1;
end

function [match1, match2]=compareBbs(bbs1, bbs2, thr, plural)
% USE bbGt('evalRes') instead
% OUTPUTS
%  match1   - [mx5] ground truth results [x y w h match]
%  match2   - [nx6] detection results [x y w h score match]

  assert(nargin<5, 'too many arguments');
  if(~plural)
    [match1,match2]=bbGt('evalRes',bbs1,bbs2,[thr]); %mul
  else
    % #TODO
    % bbGt evalRes make it accomodate 'people' label that contains a person
  end
  match1=match1(:,1:5); match2=match2(:,[1:4,6]);
end

function gt=query_gt(varargin)
% USAGE 
%   detections=alQueries('query_gt','path',path);
%   detections=alQueries('query_gt','dataDir',dataDir,'index',index);
%   detections=alQueries('query_gt','dataDir',dataDir,'name',name);
%   detections=alQueries('query_gt','dataDir',dataDir,'name',name,'singular',singular,'plural',plural);
%
% INPUTS
%   path       - absolute path of the target image
%   dataDir    - directory that contains the target image
%   index      - index of the target image in the directory
%   name       - name of the target image in directory
%   singular   - label for singular object, e.g. 'person'
%   plural     - label for plural object, e.g. 'people'
%
% OUTPUTS
%   gt - 5xN detection results. Fifth row is plural or not
%
  df={'path','','dataDir','','index','', 'name','','singular','' ,'plural',''};
  [path,dataDir,index,name,singular,plural]=getPrmDflt(varargin,df,1);

  if(~isempty(path)); assert(isempty(dataDir),'wrong arguments'); fname=path; end;
  if(~isempty(dataDir)); 
    if(~isempty(index)); assert(isempty(name),'wrong arguments');
      fname=bbGt('getFiles',{[dataDir]},index,index); 
      fname=fname{1};
    else; assert(isempty(index),'wrong arguments');
      fname=[dataDir '/' name];
    end; 
  end;
  pLoad={};

  if(~isempty(singular)|~isempty(plural)); 
    assert(~isempty(singular)&~isempty(plural), 'specify both singular and plural');
    pLoad={'lbls',{singular},'ilbls',{plural}}
  end

  [objs,gt]=bbGt('bbLoad',fname,pLoad);

end

function [fs]=mulGetFiles(dirs,fs1,fs2)
% mulGetFiles function is a variant of bbGt('getFiles') 
% The function receives a cell of directories and returns files within all of 
% the given directories. 
  fs={};

  if(numel(dirs)==2); 
    dir1=dirs{1}; dir2=dirs{2}; assert(numel(dir1)==numel(dir2));
    num_dir=numel(dir1);

    if(nargin<2 || isempty(fs1)); fs1(1:num_dir)=1; 
    else; n_fs1=numel(fs1); if(n_fs1<num_dir); fs1(n_fs1+1:num_dir)=1; end; end;
    if(nargin<3 || isempty(fs2)); fs2(1:num_dir)=Inf; 
    else; n_fs2=numel(fs2); if(n_fs2<num_dir); fs2(n_fs2+1:num_dir)=Inf; end; end;

    for i=1:num_dir
      fs=[fs bbGt('getFiles',{dir1{i},dir2{i}},fs1(i),fs2(i))];
    end

  else
    assert(numel(dirs)==1,'wrong dirs');
    dir1=dirs{1}; num_dir=numel(dir1);
    if(nargin<2 || isempty(fs1)); fs1(1:num_dir)=1; 
    else; n_fs1=numel(fs1); if(n_fs1<num_dir); fs1(n_fs1+1:num_dir)=1; end; end;
    if(nargin<3 || isempty(fs2)); fs2(1:num_dir)=Inf; 
    else; n_fs2=numel(fs2); if(n_fs2<num_dir); fs2(n_fs2+1:num_dir)=Inf; end; end;

    for i=1:num_dir
      fs=[fs bbGt('getFiles',dir1(i),fs1(i),fs2(i))];
    end
  end

end

function [fs]=mulGetFilesReversed(dirs,fs1,fs2)
% mulGetFiles function is a variant of bbGt('getFiles') 
% The function receives a cell of directories and returns files within all of 
% the given directories. 
  fs={};

  if(numel(dirs)==2); 
    dir1=dirs{2}; dir2=dirs{1}; assert(numel(dir1)==numel(dir2));
    num_dir=numel(dir1);

    if(nargin<2 || isempty(fs1)); fs1(1:num_dir)=1; 
    else; n_fs1=numel(fs1); if(n_fs1<num_dir); fs1(n_fs1+1:num_dir)=1; end; end;
    if(nargin<3 || isempty(fs2)); fs2(1:num_dir)=Inf; 
    else; n_fs2=numel(fs2); if(n_fs2<num_dir); fs2(n_fs2+1:num_dir)=Inf; end; end;

    for i=1:num_dir
      fs=[fs bbGt('getFiles',{dir1{i},dir2{i}},fs1(i),fs2(i))];
    end
    fs=flipud(fs);
  else
    assert(numel(dirs)==1,'wrong dirs');
    dir1=dirs{1}; num_dir=numel(dir1);
    if(nargin<2 || isempty(fs1)); fs1(1:num_dir)=1; 
    else; n_fs1=numel(fs1); if(n_fs1<num_dir); fs1(n_fs1+1:num_dir)=1; end; end;
    if(nargin<3 || isempty(fs2)); fs2(1:num_dir)=Inf; 
    else; n_fs2=numel(fs2); if(n_fs2<num_dir); fs2(n_fs2+1:num_dir)=Inf; end; end;

    for i=1:num_dir
      fs=[fs bbGt('getFiles',dir1(i),fs1(i),fs2(i))];
    end
  end

end

function [cell_im,array_im]=readIm(dataDir,ind1,ind2)
%
% dataDir   - this could be a string that points to a directory
%             or a cell array of image file names to read
%
  if(nargin<2 ||isempty(ind1)); ind1=1; end;
  if(nargin<3 ||isempty(ind2)); ind2=Inf; end;
  if(~iscell(dataDir))
    imgNms=bbGt('getFiles',{[dataDir]});
  else
    imgNms=dataDir;
  end
  if(ind1<1); in1=1; end;
  if(ind2>size(imgNms,2)); ind2=size(imgNms,2);end;
  imgNms=imgNms(:,ind1:ind2);
  cell_im={};

  for i=1:numel(imgNms)
    im=imread(imgNms{i});
    array_im(:,:,:,i)=im;
    cell_im{i}=im;
  end

end


function [precision,recall]=track_performance(trackDir,gtDir,pLoad)
% INPUTS
%  gtDir         - {} locations of ground truth
%  trackDir      - {} locations of tracked results
  if(isempty(pLoad)); pLoad={}; end;

  files=alQueries('mulGetFiles',({trackDir,gtDir}));
  track_files=files(1,:); gt_files=files(2,:);

  gt={}; tt={};

  for i=1:numel(gt_files)
    [~,track]=bbGt('bbLoad',track_files{i},pLoad);
    [~,ground]=bbGt('bbLoad',gt_files{i},pLoad);
    tt{end+1}=track;
    gt{end+1}=ground;
  end
  [gt,tt] = bbGt('evalRes',gt,tt,0.5,0);
  
  positive=0; true_positive=0; true0=0;
for i=1:numel(gt);
  g=gt{i}; t=tt{i}; t=t(t(:,5)==0,:); g=g(g(:,5)~=-1,:); 
  positive=positive+size(t,1); true0=true0+size(g,1);
  true_positive=true_positive+sum(t(:,6)==1);
end

precision=true_positive/positive;
recall=true_positive/true0;

end

function [gt0, dt0]=loadAll(gtDir, dtDir)
% This function is used to load tracked gt and real gt
%
% INPUTS
%  gtDir      - {} location of ground truth
%  dtDir      - {} optional location of detections
%
% OUTPUTS
%  gt0        - {1xn} loaded ground truth bbs (each is a mx5 array of bbs)
%  dt0        - {1xn} loaded detections (each is a mx5 array of bbs)
  mulGetFiles({dtDir, gtDir});

end

function result=test(varargin)
  df={'a',[],'b','','c',3};
  [a,b,c]=getPrmDflt(varargin,df,1)
  nargin  
  result=1;

end