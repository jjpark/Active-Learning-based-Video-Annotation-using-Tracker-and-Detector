function tracking_demo(dataDir,start,ending)
	prm.simThr=0.70;
	prev=pwd;
	cd(dataDir);
	clear I
	counter=1;
	for i=start:ending
	im=imread(['I',sprintf('%05d',i),'.jpg']);
	I(:,:,:,counter)=im;
	counter=counter+1;
	end
	clear counter;
	kernelTracker(I,prm)
	cd(prev);
end