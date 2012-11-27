% basic_functionality.m
%
% Test module to ensure that the NRS Classifier exists and can be called.

needed_file_list = {'nrs_classifier.m'};
fprintf('Basic Functionality Test Module:\n');

%% File existence check
fprintf('  Existence Check...\n');
error_flag = 0;
for i=1:length(needed_file_list)
    filename = needed_file_list{i};
    if exist(filename,'file')
        fprintf('    * %s...located.\n',filename);
    else
        error_flag = 1;
        fprintf('    * %s...missing.\n',filename);
    end
end

if error_flag
  error('basic_functionality:MissingFile','Failure in basic_functionality: Missing files.');  
end

