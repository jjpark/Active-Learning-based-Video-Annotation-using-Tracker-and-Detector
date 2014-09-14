function detector=alTraining(name,poGtDir,posImgDir,negWinDir,nNeg,nAccNeg,draw,varargin)
opts=acfTrain(); opts.modelDs=[50 20.5]; opts.modelDsPad=[64 32];
opts.winsSave=1;
opts.pPyramid.smooth=.5; opts.pPyramid.pChns.pColor.smooth=0;
opts.posGtDir=[poGtDir]; opts.nWeak=[32 128 512 2048];
opts.posImgDir=[posImgDir]; opts.pJitter=struct('flip',1);
opts.negWinDir=[negWinDir]; opts.nNeg=nNeg; opts.nAccNeg=nAccNeg;
opts.pBoost.pTree.fracFtrs=1/16; opts.name=name;
pLoad={'lbls',{'person','people'},'squarify',{3,.41}};
opts.pLoad = [pLoad 'hRng',[50 inf], 'vRng',[1 1] ];

%% train detector (see acfTrain)
detector = acfTrain( opts );

%% modify detector (see acfModify)
detector = acfModify(detector,'cascThr',-1,'cascCal',-.005);
%% run detector on a sample image (see acfDetect)

if(draw&&~isempty(varargin)); draw_image(detector,[varargin{1}],1); end;

end