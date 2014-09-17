function varargout = performTrack(action, varargin)
% Author: Jeong Joon Park 2014
% Idea note: frame a key frame, also track to back several frames

varargout = cell(1,max(1,nargout));
[varargout{:}] = feval(action,varargin{:});
end

function [precision,recall]=track_performance(varargin)
% 
% INPUTS
%  gtDir         - {} locations of ground truth
%  trackDir      - {} locations of tracked results
  df={'trackDir','','gtDir','','track0','', 'gt0','','pLoad',{}};
  [trackDir,gtDir,track0,gt0,pLoad]=getPrmDflt(varargin,df,1);

  if(isempty(pLoad)); pLoad={}; end;

  if(~isempty(trackDir)&~isempty(gtDir))
    files=alQueries('mulGetFiles',({trackDir,gtDir}));
    track_files=files(1,:); gt_files=files(2,:);

    gt={}; tt={};

    for i=1:numel(gt_files)
      [~,track]=bbGt('bbLoad',track_files{i},pLoad);
      [~,ground]=bbGt('bbLoad',gt_files{i},pLoad);
      tt{end+1}=track;
      gt{end+1}=ground;
    end

  elseif(~isempty(gtDir)&isempty(trackDir)&~isempty(track0))
    sz=numel(track0);
    files=alQueries('mulGetFiles',{gtDir},1,sz);
    assert(numel(track0)==numel(files));
    gt={};
    for i=1:numel(files)
      [~,ground]=bbGt('bbLoad',files{i},pLoad);
      gt{end+1}=ground;
    end
    tt=track0;

  else
    gt=gt0; tt=track0;
  end

  [gt,tt] = bbGt('evalRes',gt,tt,0.3,0);
  
  positive=0; true_positive=0; true0=0;
for i=1:numel(gt);
  g=gt{i}; t=tt{i}; t=t(t(:,5)==0,:); t=t(t(:,6)~=-1,:); g=g(g(:,5)~=-1,:); 
  positive=positive+size(t,1); true0=true0+size(g,1);
  true_positive=true_positive+sum(t(:,6)==1);
end
positive
true0
true_positive
precision=true_positive/positive
recall=true_positive/true0

end

function [I]=drawBb(I,bbs,color)
% color - [R,G,B] array of integers between 1~255
  [col,row,~]=size(I);
  bbs=floor(bbs);
  num=size(bbs,1);
  for i=1:num
    bb=bbs(i,1:4); bb=max(bb,2); x=min(bb(1),row); y=min(bb(2),col);
    w=min(bb(3),row-x-1);; h=min(bb(4),col-y-1);
    I(y:y+1,x:x+w,1)=color(1); I(y:y+1,x:x+w,2)=color(2); I(y:y+1,x:x+w,3)=color(3); 
    I(y+h-1:y+h,x:x+w,1)=color(1); I(y+h-1:y+h,x:x+w,2)=color(2); I(y+h-1:y+h,x:x+w,3)=color(3); 
    I(y:y+h,x:x+1,1)=color(1);I(y:y+h,x:x+1,2)=color(2);I(y:y+h,x:x+1,3)=color(3);
    I(y:y+h,x-1+w:x+w,1)=color(1);I(y:y+h,x+w-1:x+w,2)=color(2);I(y:y+h,x+w-1:x+w,3)=color(3);
  end
  I=I(1:col,1:row,:);
end

function [result]=generateBbVideo(gtDir,imDir,targetDir,name)
  f=bbGt('getFiles',{gtDir,imDir});
  f=flipud(f);

  I=imread(f{1,1}); [col,row,~]=size(I)
  I=[];

  info=struct('height',col,'width',row,'codec','raw','fps',30);
  h=seqWriterPlugin('open',[],name,info);

  for i=1:size(f,2)
    I=imread(f{1,i});
    [~,bbs]=bbGt('bbLoad',f{2,i});
    I=drawBb(I,bbs,[0,255,0]);
    seqWriterPlugin('addframe',h,I);
  end
  seqWriterPlugin('close',h);
  result=0;
end

function [dir]=generateSeqVideo(imDir,targetDir,name)
%
%
  f=bbGt('getFiles',imDir);
  I=imread(f{1}); [col,row,~]=size(I)
  clear I;
  info=struct('height',col,'width',row,'codec','raw','fps',30);
  h=seqWriterPlugin('open',[],name,info);

  for i=1:numel(f)
    I=imread(f{i}); 
    seqWriterPlugin('addframe',h,I);
  end

  seqWriterPlugin('close',h);

  dir=[targetDir '/' name];

end

function [result]=testTracker(gtRate,imDir,gtDir,imRange,name)
  f=bbGt('getFiles',{imDir,gtDir},imRange(1),imRange(2));
  I=imread(f{1}); [col,row,~]=size(I)
  I=[];

  info=struct('height',col,'width',row,'codec','raw','fps',30);
  h=seqWriterPlugin('open',[],name,info);

  prmTrack.maxProb=50;
  tracker=[];

  for i=1:size(f,2)
    I=imread(f{1,i}); 
    if(rem(i,gtRate)==1)
      [~,bbs]=bbGt('bbLoad',f{2,i});
    else
      bbs=evaluateCTTracker(I,tracker);
    end
    bbs
    tracker=manageTracker('updateTWithGt','updateCTTracker',I,tracker,bbs,prmTrack);
    I=drawBb(I,bbs,[0,255,0]);

    seqWriterPlugin('addframe',h,I);
  end

  seqWriterPlugin('close',h);
  seqPlayer(name);
end

function [precision, recall]=testKernelTracker(gtRate,imDir,gtDir,imRange,name,prTest,play)
  f=bbGt('getFiles',{imDir,gtDir},imRange(1),imRange(2));

  I=imread(f{1}); [col,row,~]=size(I)
  I=[];
  pLoad={};
  if(prTest)
    track0={};
    pLoad={'lbls',{'person'},'ilbls',{'people'},'squarify',{3,.41}};
    pLoad=[pLoad, 'hRng',[50 inf],...
    'vRng',[.65 1],'xRng',[5 635],'yRng',[5 475]];
  end

  info=struct('height',col,'width',row,'codec','raw','fps',30);
  h=seqWriterPlugin('open',[],name,info);
  disp('aa');
  bbs=[];

  for i=1:size(f,2)
    mod_gtRate=rem(i,gtRate); if mod_gtRate==0, mod_gtRate=gtRate; end;

    if(rem(i,gtRate)==1)
      [~,Is]=alQueries('readIm',imDir,i,i+gtRate-1);
      [~,bbs]=bbGt('bbLoad',f{2,i},pLoad);
      bb=bbs;
    else
      bb=alQueries('kernel_tracking_queries',Is(:,:,:,1:mod_gtRate),bbs);
    end

    I=drawBb(Is(:,:,:,mod_gtRate),bb,[0,255,0]);

    seqWriterPlugin('addframe',h,I);
    prevI=I;

    if(prTest)
      track0{end+1}=bb(:,1:5);
    end
  end

  seqWriterPlugin('close',h);

  if(prTest)
    [precision,recall]=performTrack('track_performance','track0',track0,'gtDir',{gtDir},'pLoad',pLoad);
  else
    precision=-1; recall=-1;
  end

  if(play)
    seqPlayer(name);
  end

end

function [precision, recall]=testReverseTracker(gtRate,imDir,gtDir,imRange,name,prTest,play)
  f=bbGt('getFiles',{imDir,gtDir},imRange(1),imRange(2));
  f=fliplr(f);
  imgNms=f(1,:);
  I=imread(f{1}); [col,row,~]=size(I)
  I=[];
  pLoad={};
  gt0={};
  if(prTest)
    track0={};
    
    pLoad={'lbls',{'person'},'ilbls',{'people'},'squarify',{3,.41}};
    pLoad=[pLoad, 'hRng',[50 inf],...
    'vRng',[.65 1],'xRng',[5 635],'yRng',[5 475]];
  end

  info=struct('height',col,'width',row,'codec','raw','fps',30);
  h=seqWriterPlugin('open',[],name,info);
  disp('aa');
  bbs=[];

  for i=1:size(f,2)
    mod_gtRate=rem(i,gtRate); if mod_gtRate==0, mod_gtRate=gtRate; end;
    [~,gt]=bbGt('bbLoad',f{2,i},pLoad);
    gt0{end+1}=gt;
    if(rem(i,gtRate)==1)
      [~,Is]=alQueries('readIm',imgNms,i,i+gtRate-1);
      [~,bbs]=bbGt('bbLoad',f{2,i},pLoad);
      bb=bbs;
    else
      bb=alQueries('kernel_tracking_queries',Is(:,:,:,1:mod_gtRate),bbs);
    end

    I=drawBb(Is(:,:,:,mod_gtRate),bb,[0,255,0]);

    seqWriterPlugin('addframe',h,I);
    prevI=I;

    if(prTest)
      track0{end+1}=bb(:,1:5);
    end
  end

  seqWriterPlugin('close',h);

  if(prTest)
    [precision,recall]=performTrack('track_performance','track0',track0,'gt0',gt0,'pLoad',pLoad);
  else
    precision=-1; recall=-1;
  end

  if(play)
    seqPlayer(name);
  end

end


function [result]=testKTFrame(gtRate,imDir,gtDir,imRange,name)
  f=bbGt('getFiles',{imDir,gtDir},imRange(1),imRange(2));
  I=imread(f{1}); [col,row,~]=size(I)
  I=[];

  info=struct('height',col,'width',row,'codec','raw','fps',30);
  h=seqWriterPlugin('open',[],name,info);
  
  prevI=[];
  bbs=[];

  for i=1:size(f,2)
    I=imread(f{1,i}); 
    if(rem(i,gtRate)==1)
      [~,bbs]=bbGt('bbLoad',f{2,i});
    else
      Is(:,:,:,1)=prevI; Is(:,:,:,2)=I;
      bbs=alQueries('kernel_tracking_queries',Is,bbs);
    end

    prevI=I;
    I=drawBb(I,bbs,[0,255,0]);
    seqWriterPlugin('addframe',h,I);
    
  end

  seqWriterPlugin('close',h);
  seqPlayer(name);
  result=0;
end

function [result]=testDetector(imDir,detector,name)
% imDir   - cell array of strings

  files=alQueries('mulGetFiles',{imDir});
  I=imread(files{1}); [col,row,~]=size(I)
  I=[];

  info=struct('height',col,'width',row,'codec','raw','fps',30);
  h=seqWriterPlugin('open',[],name,info);

  detections=acfDetect(files,detector);

  for i=1:numel(files);
    I=imread(files{i});
    bbs=detections{i};
    I=drawBb(I,bbs,[0,255,0]);
    seqWriterPlugin('addframe',h,I);

  end

  seqWriterPlugin('close',h);
  seqPlayer(name);
  result=0;

end

function rate=clicksPerFramesPerObjects(gtDir,gtRate) 
% gtDir is cell array of strings
  f = bbGt('getFiles',gtDir);
  clicks = 0; frames = numel(f); objects = 0;
  for i=1:frames
    [~,gt]=bbGt('bbLoad',f{i});
    objects = objects + size(gt,1);
    if(rem(i,gtRate)==1)
      clicks = clicks + size(gt,1);
    end
  end
  clicks
  frames
  objects
  
  rate = clicks / frames / objects;
end