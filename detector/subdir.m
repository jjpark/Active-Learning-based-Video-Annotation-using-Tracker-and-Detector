function varargout=subdir(action,varargin)
  curr_path=pwd;
  varargout = cell(1,max(1,nargout));
  [varargout{:}] = feval(action,varargin{:});
  cd(curr_path);
end

function [path]=get_path(index,base,keywords)
% Get paths of the given index using the keywords Only works on folders not files
%
% INPUTS
%   index    - positive integer
%   base     - base directory
%   keywords - {n} cell array containing keywords
%

end

function paths=get_all_paths(base,keywords,curr_path)
% curr_path should be {} initially
  cd(base);
  raw_folders=dir(keywords{1});
  folders={};

  for i=1:numel(raw_folders);
    if(raw_folders(i).isdir==1)
      folders{end+1}=[base '/' raw_folders(i).name];
    end
  end

  if(numel(keywords)==1)
    paths=[curr_path folders];
    return;

  else
    paths=curr_path;
    for i=1:numel(folders)
      paths=get_all_paths(folders{i},keywords(2:end),paths);
    end
  end

end