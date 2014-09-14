
function new_bboxes = consolidate_bboxes(bboxes)
%% Consolidate multiple bounding boxes to one and assigns it a likelihood 
% INPUT 
%  anno:     n x 7 matrix where each row contains information on a 
%            bounding box: [image_id worker_id x y width height confidence] 
% OUTPUT 
%  new_anno: m x 7 matrix where each row contains information on the 
%            consolidated bounding box: [image_id -1 x y width height likelihood]

likli_filter = 0.0; %likelihood filter. set to 0 to turn off the filter
im_ids = unique(bboxes(:,1));
new_box_row_index = 1;
set_num_ppl = 1;
num_participants = 5;
for i=1:numel(im_ids)
    im_id = im_ids(i);
    % store all annotations for this image
    inds = bboxes(:,1)==im_id;
    tmp_anno = bboxes(inds,:); % information for only the current image
    coordinates = tmp_anno(:,[3,4,5,6]);
    coordinates(:,1) = coordinates(:,1)+coordinates(:,3)/2;
    coordinates(:,2) = coordinates(:,2)+coordinates(:,4)/2;
    x_y = coordinates(:,[1,2]);
    worker_ids = unique(tmp_anno(:,2)); %unique work ids
    
    number_anno_per_worker = zeros(1,numel(worker_ids));
    
    for j=1:numel(worker_ids) 
        number_anno_per_worker(j) = sum(tmp_anno(:,2)==worker_ids(j));
    end
    num_cluster = max(number_anno_per_worker); %get the max number of annotations

    data=[15*x_y(:,1), 15*x_y(:,2), 20*tmp_anno(:,[3,4]),10*tmp_anno(:,[3,4]),...
        tmp_anno(:,[5,6])];
    
    if size(data,1) == 1
        IDX = 1;        
        else IDX=clusterdata(data, num_cluster); 
    end
    
    if num_cluster == 1
        IDX(:,1) = 1;
    end
    
    tmp_anno(:,8)=IDX;

    for j=1:num_cluster
       
        tmp_box_ind = tmp_anno(:,8) == j;
        tmp_box = tmp_anno(tmp_box_ind,:);
        num_anno_box = size(tmp_box,1);
        tmp_box = tmp_box(:,[1,3,4,5,6]);
        tmp_box = mean(tmp_box,1);
        if set_num_ppl == 1
            ppl = num_participants;
        else
            ppl = numel(worker_ids);
        end
        
        likely = liklihood(num_anno_box, ppl);
        if (likely > likli_filter)
            tmp_box = [tmp_box(1), -1, tmp_box([2,3,4,5]),likely];
            new_bboxes(new_box_row_index,:) = tmp_box;
            new_box_row_index = new_box_row_index + 1;
        end
    end
    
    %scatter(x_y(:,1),x_y(:,2),50,IDX,'filled') % this for debug plotting

end
end

function new_array = remove_outliers(array)
    old_array = array;
    new_array = old_array;
    aver = mean(old_array);
    stan_dev = std(old_array);
    ind=zeros(1,numel(array));
    for i = 1: numel(old_array)
        if abs(old_array(i)-aver) > stan_dev * 1
            old_array(i) = []
        end
    end
    new_array = old_array;
end

function lik=liklihood(num_pts, num_ppl)
    num_not = num_ppl - num_pts;
    true_positive = 0.8;
    false_negative = 0.9;
    input = 0.8^num_pts * 0.2^(num_not)/ (0.9^num_not*0.1^num_pts);
    r = log10(input);
    lik = 10^r/(1+10^r);
end





