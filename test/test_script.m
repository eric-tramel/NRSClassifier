% test_script.m
%
% This script is intended to verify the operation of the NRS classifier.
% Running this script will report any known (checked-for) errors in the NRS 
% classifier. This script should be run as large changes are made to the
% repository to ensure nothing broken is uploaded to the repo. As new
% features are added to the NRS classifier, this script (and any other
% scripts or funcitons it calls) should be updated to reflect the new
% functionality.
clear; clc;
addpath(genpath('..'));
test_failure = 0;

%% Test the basics
try
basic_functionality  % Run Module
catch err
    if ~strcmp(err.identifier,'basic_functionality:MissingFile')
        rethrow(err);
    else
        test_failure = 1;
    end
end

%% Dummy run
try
dummy_run  % Run Module
catch err
    if ~strcmp(err.identifier,'basic_functionality:MissingFile')
        rethrow(err);
    else
        test_failure = 1;
    end
end



%% Pass/Fail Reporting
fprintf('======================================\n');
if ~test_failure
    fprintf('\ntest_script: ***PASS***\n');
else
    fprintf('\ntest_script: ***FAIL***\n');
end