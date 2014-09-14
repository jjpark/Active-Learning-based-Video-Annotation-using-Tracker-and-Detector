function tracker=updateCSKTracker(I,tracker,initBB,prmTrack)
%% Convert Frame to Grayscale and Normalise
if(isempty(I)), return; end
if(size(I,3)==3), I = rgb2gray(I); end

%% Initialise New Tracker using the bounding box given in initBB
if(isempty(tracker))

    %% Assign Parameters
    maxProb=prmTrack.maxProb;
    
    %parameters according to the paper
    padding = 1;					%extra area surrounding the target
    output_sigma_factor = 1/16;		%spatial bandwidth (proportional to target)
    sigma = 0.2;					%gaussian kernel bandwidth
    lambda = 1e-2;					%regularization
    interp_factor = 0.075;			%linear interpolation factor for adaptation
    
    target_sz = [initBB(4), initBB(3)];
    
    %window size, taking padding into account
    sz = floor(target_sz * (1 + padding));
    
    %desired output (gaussian shaped), bandwidth proportional to target size
    output_sigma = sqrt(prod(target_sz)) * output_sigma_factor;
    [rs, cs] = ndgrid((1:sz(1)) - floor(sz(1)/2), (1:sz(2)) - floor(sz(2)/2));
    y = exp(-0.5 / output_sigma^2 * (rs.^2 + cs.^2));
    yf = fft2(y);
    
    %store pre-computed cosine window
    cos_window = hann(sz(1)) * hann(sz(2))';
else
    % Unwrap Tracker
    sz=tracker.sz; cos_window=tracker.cos_window; sigma=tracker.sigma;
    yf=tracker.yf; lambda=tracker.lambda; interp_factor=tracker.interp_factor;
    alphaf=tracker.alphaf; z=tracker.z; target_sz=tracker.target_sz; 
    maxProb=tracker.maxProb;  
end

%% Update Tracker

%get subwindow at current estimated target position, to train classifer
pos = [initBB(2), initBB(1)] + floor(target_sz/2);
x = get_subwindow(I, pos, sz, cos_window);

%Kernel Regularized Least-Squares, calculate alphas (in Fourier domain)
k = dense_gauss_kernel(sigma, x);
new_alphaf = yf ./ (fft2(k) + lambda);   %(Eq. 7)
new_z = x;

if(isempty(tracker)) %first time, train with a single image
    alphaf = new_alphaf;
    z = x;
else
    %subsequent frames, interpolate model
    alphaf = (1 - interp_factor) * alphaf + interp_factor * new_alphaf;
    z = (1 - interp_factor) * z + interp_factor * new_z;
end

tracker=struct('sz',sz,'cos_window',cos_window,'sigma',sigma,...
        'yf',yf,'lambda',lambda,'interp_factor',interp_factor,...
        'alphaf',alphaf,'z',z,'target_sz',target_sz,'prevBB',initBB,...
        'maxProb',maxProb);

