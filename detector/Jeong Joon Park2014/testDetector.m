function [gt,tt]=testDetector(detector,imDir,gtDir,pLoad) 
	if (isempty(pLoad)); pLoad={}; end;
	files=bbGt('getFiles',{imDir, gtDir});
	ims=files(1,:); annos=files(2,:);
	detections=acfDetect(ims,detector);

	assert(numel(detections)==size(files,2));

	gt={};

	for i=1:numel(detections)
		[~,gt{end+1}]=bbGt('bbLoad',annos{i},pLoad);
	end

	[gt,tt]=bbGt('evalRes',gt,detections,0.5,0);

	positive=0; true_positive=0; true0=0;
	for i=1:numel(gt);
	  g=gt{i}; t=tt{i}; t=t(t(:,6)~=-1,:); g=g(g(:,5)~=-1,:); 
	  positive=positive+size(t,1); true0=true0+size(g,1);
	  true_positive=true_positive+sum(t(:,6)==1);
	end
	positive
	true0
	true_positive
	precision=true_positive/positive
	recall=true_positive/true0
end