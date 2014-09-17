base='/home/jj/vision/caltech-whole/annotations';
all_sets=dir('set*');
for i=1:numel(all_sets)
	all_set_names{i}=all_sets(i).name;
end
clear all_sets;
no_sets=dir('*.*');
for i=1:numel(no_sets)
	no_set_names{i}=no_sets(i).name;
end
clear no_sets;
sets=setdiff(all_set_names,no_set_names);
clear all_set_names; clear no_set_names;


%seqIo(['/V000'],'toImgs',['V000']);
for j=1:numel(sets)
	cd(sets{j});
	pwd
	vs_t=dir('*.vbb');
	for i=1:numel(vs_t)
		vs{i}=vs_t(i).name;
	end
	clear vs_t;
	vs
	for i=1:numel(vs)
		name=vs{i}(1:end-4);
		V=vbb('vbbLoad',name);
		 vbb('vbbToFiles',V,name);
	end
	clear vs
	cd(base)
	pwd
end