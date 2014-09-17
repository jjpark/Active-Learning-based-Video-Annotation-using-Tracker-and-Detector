function json_to_gt(data_dir, target_pos,target_posGt,target_neg)
% This function creates ${image}.txt files that contain annotated ground truth of ${image}
% target_pos indicates the directory to send the positive images to
% target_posGt indicates the directory to send the ground truth of positive samples
% target_neg indicates the directory to send the negative images to
% data_dir indicates the directory where the cropped images and json file is located
	
	data_dir='data/inria/cropped/'
	form=[data_dir '*.json']
	json_dir=dir(form);
	json_dir=json_dir.name;
	json_to_anno(fullfile([data_dir json_dir]));

	data_dir='data/inria/cropped/'
	form=[data_dir '*.mat']
	json_dir=dir(form);
	json_dir=json_dir.name
	load(fullfile(data_dir, json_dir));

	bboxes=anno.bboxes;
	new_bboxes=consolidate_bboxes(bboxes);

	names=anno.image_names;
	names=names';
	pos_nms=new_bboxes(:,1);
	pos_nms=sort(unique(pos_nms,'first'));	
	pos_names=names(pos_nms);
	[neg_names,~]=removerows(names,'ind',pos_nms);
	for i=1:numel(pos_names)
		img_nm=pos_names(i); % note that img_nm is a cell. it's weird
		img_nm=img_nm{1};
		system(['mv ' data_dir img_nm ' ' target_pos '/cropped_' img_nm])
		img_number=pos_nms(i);

        try
            % try to load image from source
            img = imread(fullfile(anno.image_names{img_number}));
        catch err
            % if source image is not available, load from url
            img = imread(anno.image_urls{img_number});
            disp('Could not find image source, loading image from url')
        end
        [height,width,~]=size(img)
        fid=fopen([data_dir 'pos/cropped_' img_nm(1:end-4) '.txt'],'wt');
        fprintf(fid, '%% bbGt version=3\n');
        fprintf(fid,['person 1 1 ' int2str(width-2) ' ' int2str(height-2) ' 0 0 0 0 0 0 0\n' ]);

	end

	for i=1:numel(neg_names)
		img_nm=neg_names(i);
		img_nm=img_nm{1};
		system(['mv ' data_dir img_nm ' ' target_neg '/cropped_' img_nm]);
	end

	movefile('data/inria/cropped/pos/*.png', 'data/inria/train/pos_current')
	movefile('data/inria/cropped/pos/*.txt', 'data/inria/train/posGt_current')
	movefile('data/inria/cropped/neg/*.png', 'data/inria/train/neg')

end