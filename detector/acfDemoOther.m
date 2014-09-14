dataDir = 'data/inria/';

%{
for s=1:2
  if(s==1), set='00'; type='train'; else set='01'; type='test'; end
  if(exist([dataDir type '/posGt'],'dir')), continue; end
    disp('aa')
  seqIo([dataDir 'set' set '/V000'],'toImgs',[dataDir type '/pos']);
  seqIo([dataDir 'set' set '/V001'],'toImgs',[dataDir type '/neg']);
  V=vbb('vbbLoad',[dataDir 'annotations/set' set '/V000']);
  vbb('vbbToFiles',V,[dataDir type '/posGt']);
end
%}

%% set up opts for training detector (see acfTrain)
opts=acfTrain(); opts.modelDs=[100 41]; opts.modelDsPad=[128 64];
opts.nWeak=[32 128 512 2048];
opts.posWinDir=['data/pedestrians128x64']; opts.pJitter=struct('flip',1);
opts.negImgDir=[dataDir 'train/neg'];
opts.winsSave=1;
opts.name='models/AcfOther';

global detector;
%% train detector (see acfTrain)
detector = acfTrain( opts );

%% modify detector (see acfModify)
detector = acfModify(detector,'cascThr',-1,'cascCal',0);
save('detector','detector')
%% run detector on a sample image (see acfDetect)

draw_image(detector,['data/caltech-whole/set00/V10']);
