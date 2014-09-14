function bbs=evaluateCSKTracker(I,tracker)
N=length(tracker); bbs=zeros(N,6);
if(isempty(tracker)), return; end
%% Convert Frame to Grayscale and Normalise
if (size(I,3)==3), I = rgb2gray(I); end

%% Evaluate Tracker
kk=0;
for k=1:N
    % Unwrap Tracker
    tracker1=tracker(k).tracker;
    sz=tracker1.sz; cos_window=tracker1.cos_window; sigma=tracker1.sigma;
    alphaf=tracker1.alphaf; z=tracker1.z; target_sz=tracker1.target_sz;
    prevBB=tracker1.prevBB; maxProb=tracker1.maxProb;
    
    % Evaluate Tracker on Image
    pos = [prevBB(2), prevBB(1)] + floor(target_sz/2);
    x = get_subwindow(I, pos, sz, cos_window);
    
    %calculate response of the classifier at all locations
    K = dense_gauss_kernel(sigma, x, z);
    response = real(ifft2(alphaf .* fft2(K)));   %(Eq. 9)
    
    %target location is at the maximum response
    probm=max(response(:));
    [row, col] = find(response == probm, 1);
    pos = pos - floor(sz/2) + [row, col];
    if(probm > maxProb)
        kk=kk+1;
        bbs(kk,:) = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])...
                    probm tracker(k).id];
    end
end
bbs=bbs(1:kk,:);
end