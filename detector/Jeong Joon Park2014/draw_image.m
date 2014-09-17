% varargin for showing ground truth

function draw_image(detector,dataDir,im_start)
	im_num = im_start;
  fig=figure(1);
    uicontrol('Style', 'pushbutton', 'String', '>',...
            'Units','normalized',...
            'Position', [.56 .02 .05 .05],...
            'Callback', @im_up);    
    uicontrol('Style', 'pushbutton', 'String', '<',...
            'Units','normalized',...
            'Position', [.39 .02 .05 .05],...
            'Callback', @im_down);
  %% run detector on a sample image (see acfDetect)
imgNms=bbGt('getFiles',{[dataDir]});
I=imread(imgNms{im_num});  bbs=acfDetect(I,detector); 
bbs
figure(1); im(I); bbApply('draw',bbs); %bbApply('draw',bbs); pause(.1);

  function im_up(hObj,event)
    refresh(fig);
    im_num=min(numel(imgNms),im_num + 1)
I=imread(imgNms{im_num});  bbs=acfDetect(I,detector); 
bbs
im(I); bbApply('draw',bbs); 
  end
  function im_down(hObj,event)
    im_num=max(1,im_num -1);
I=imread(imgNms{im_num}); bbs=acfDetect(I,detector); 
bbs
im(I); bbApply('draw',bbs); 
  end

end

