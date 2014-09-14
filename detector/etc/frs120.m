base='/home/jj/vision/caltech-whole';
im_paths=subdir('get_all_paths',base,{'set*','*V*'},{});
anno_im=subdir('get_all_paths',base,{'set*','*V*','*anno_im*'},{});
anno_gt=subdir('get_all_paths',base,{'set*','*V*','*anno_gt*'},{});
base='/home/jj/vision/caltech-whole/annotations';
anno_paths=subdir('get_all_paths',base,{'set*','*V*'},{});

sampling_r=30;

for i=11:11
	im_paths{i}
	imgs=alQueries('mulGetFiles',{im_paths(i),anno_paths(i)});
	im_copy_to=anno_im{i}; anno_copy_to=anno_gt{i};
	for j=1:(size(imgs,2)-1)/sampling_r+1
		ind=(j-1)*sampling_r+1;
		copyfile(imgs{1,ind},im_copy_to);
		copyfile(imgs{2,ind},anno_copy_to);
	end
end