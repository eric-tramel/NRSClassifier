function [y ordering] = convert_labels(x,C)
% [y, ordering] = convert_labels(x,C)
% Convert from short form labelling to long form labelling and so forth
% Output: 
%   y  -- The converted labels
%   ordering -- Used when converting from long to short form. Returns
%               the final ordering so that the dataset can be 
%               rearranged if need be.

d = length(x);

% Check which conversion mode we're in
if d ~= C
    LONG_TO_SHORT = 1;
else
    LONG_TO_SHORT = 0;
end

y = [];

if LONG_TO_SHORT
% Convert from long form labelling to short form labelling
	[sorted_labels ordering] = sort(x,'ascend');
	y = hist(x,unique(sorted_labels));
else
% Convert from short form labelling to long form labelling
    for i=1:d
        y = [y i*ones(1,x(i))];
    end
end