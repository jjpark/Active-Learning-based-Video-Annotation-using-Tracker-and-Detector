

function json_to_anno(json_file)
%% Convert *.json annotation files anno structure and saves to *_anno.mat 
% The anno structure contains the following fields:
%
% .image_names       original image names
% .image_urls        links to images on mturk website
% .annos_per_image   number of annotators per image
% .bboxes            n_bboxes x 7 matrix where each row represents one  
%                    bounding box with fields:
%                    [image id, worker id, x, y, width, height, certainty]

% read the annotation file
json = fileread(json_file);
data = parse_json(json);

% keep track of images
image_alias = fields(data.images);      % name used on mturk
n_images = numel(image_alias);          % number of images
image_names = cell(1,n_images);         % original names
image_urls = cell(1,n_images);          % mturk urls to images
annos_per_image = zeros(1,n_images);    % number of annotators per image
for i=1:n_images
    image_names{i} = data.images.(image_alias{i}).original_name;
    image_urls{i} = data.images.(image_alias{i}).url;
end

% keep track of workers
n_workers = numel(data.annotations);
workers = cell(1,n_workers);
for i=1:n_workers
    workers{i} = data.annotations{1}.worker;
end

% initialize bboxes
bboxes = zeros(n_workers*10,7); % im_id, worker_id, x, y, width, height, certainty

% load annotations
count = 0;
for worker_id=1:numel(data.annotations)

    % images labeled by this annotator
    labeled_imgs = fields(data.annotations{worker_id}.answer.images);

    % find bboxes for each image
    for i=1:numel(labeled_imgs)                

        % image id
        im_id = find(strcmp(labeled_imgs{i},image_alias));

        % increase annotations for this image
        annos_per_image(im_id) = annos_per_image(im_id) + 1;

        % loop through all bboxes
        boxes = data.annotations{worker_id}.answer.images.(labeled_imgs{i});
        for b=1:numel(boxes)    
            if isempty(boxes{b})
                continue
            end

            c_x = boxes{b}{2}.x;
            c_y = boxes{b}{2}.y;
            width = boxes{b}{2}.scaleX;
            height = boxes{b}{2}.scaleY;
            x = c_x - width/2;
            y = c_y - height/2;

            count = count + 1;                                        
            bboxes(count,:) = [im_id worker_id x y width height -1];
        end
    end
end
bboxes = bboxes(1:count,:);

% set up the anno structure
anno.image_names = image_names;
anno.image_urls = image_urls;
anno.annos_per_image = annos_per_image;
anno.workers = workers;
anno.bboxes = bboxes;

% save the structure to a file
[dir_name,json_name] = fileparts(json_file);
save(fullfile(dir_name,[json_name '_anno.mat']),'anno');

end