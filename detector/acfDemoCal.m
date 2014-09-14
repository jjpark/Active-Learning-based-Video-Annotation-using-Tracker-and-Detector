% Demo for aggregate channel features object detector on Caltech dataset.
%
% (1) Download data and helper routines from Caltech Peds Website
%  www.vision.caltech.edu/Image_Datasets/CaltechPedestrians/
%  (1a) Download Caltech files: set*.tar and annotations.zip
%  (1b) Copy above files to dataDir/data-USA/ and untar/unzip contents
%  (1c) Download evaluation code (routines necessary for extracting images)
% (2) Set dataDir/ variable below to point to location of Caltech data.
% (3) Launch "matlabpool open" for faster training if available.
% (4) Run demo script and enjoy your newly minted fast ped detector!
%
% Note: pre-trained model files are provided (delete to re-train).
% Re-training may give slightly variable results on different machines.
%
% Piotr's Image&Video Toolbox      Version 3.23
% Copyright 2013 Piotr Dollar & Ron Appel.  [pdollar-at-caltech.edu]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the Simplified BSD License [see external/bsd.txt]
disp('120frs!')
%% extract training and testing images and ground truth
dataDir='/home/jj/vision/caltech-whole';
%{
for s=1:2
  if(s==1), type='train'; else type='test'; end
  if(exist([dataDir type '/annotations'],'dir')), continue; end
  dbInfo(['Usa' type]); dbExtract([dataDir type],1);
end
%}
%% set up opts for training detector (see acfTrain)
opts=acfTrain(); opts.modelDs=[50 20.5]; opts.modelDsPad=[64 32];
opts.winsSave=0;
opts.pPyramid.smooth=.5; opts.pPyramid.pChns.pColor.smooth=0;
opts.posGtDir=track_gt(10); 
opts.nWeak=[32 128 512 2048];
opts.posImgDir=im_paths(10); opts.pJitter=struct('flip',1);
%opts.negWinDir=['data/caltech-whole/negatives']; 
opts.nNeg=20000+20000; opts.nAccNeg=80000+80000; opts.nPerNeg=2*floor(20000/2168);
opts.pBoost.pTree.fracFtrs=1/16; opts.name='models/set00V011tracked3frs';
pLoad={'lbls',{'person'},'ilbls',{'people'},'squarify',{3,.41}};
opts.pLoad = [pLoad 'hRng',[50 inf], 'vRng',[1 1] ];

%% train detector (see acfTrain) acfTrain when posImgDir and posGtDir matches
%% if there is less files in posGtDir, then call train2
detector = train2( opts );

%% modify detector (see acfModify)
detector = acfModify(detector,'cascThr',-1,'cascCal',-.005);
%% run detector on a sample image (see acfDetect)
save([opts.name 'Detector.mat'],'detector');

draw_image(detector,[im_paths{11}],1);


%% test detector and plot roc (see acfTest)
[~,~,gt,dt]=acfTest('detector',detector,'name',ops.name,'imgDir',im_paths{10},...
  'gtDir',anno_paths{10},'pLoad',[pLoad, 'hRng',[50 inf],...
  'vRng',[.65 1],'xRng',[5 635],'yRng',[5 475]],'show',1,'reapply',1);
%{
%% optionally show top false positives ('type' can be 'fp','fn','tp','dt')
if( 0 ), bbGt('cropRes',gt,dt,imgNms,'type','fn','n',50,...
    'show',3,'dims',opts.modelDs([2 1])); end

% for name in *.jpg; do mv "${name}" "${index}.jpg"; index=$((index+1)); done
%}