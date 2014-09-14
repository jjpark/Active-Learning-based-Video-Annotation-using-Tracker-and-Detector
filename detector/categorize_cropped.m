%%%% categorize the cropped files with annotation from mturk
%%%% this is just for the demo. In reality put it somewhere else.
dataDir='data/inria/cropped/';
json_to_gt(dataDir,[dataDir 'pos'],'',[dataDir 'neg']);
