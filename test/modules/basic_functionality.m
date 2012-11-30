function passed = basic_functionality()
% basic_functionality.m
%
% Test module to ensure that the NRS Classifier exists and can be called.

needed_file_list = {'nrs_classifier.m'};

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

passed = ~error_flag;