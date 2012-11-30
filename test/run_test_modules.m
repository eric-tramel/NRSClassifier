% run_test_modules.m 
%
% This function will run all of the test modules conatined in the
% the './modules' directory. An arbitrary number of modules may be
% included in this directory. This script will run them all
% and give a final reporting analysis.
%
% Currently uses eval...there might be a better solution out there.
addpath('./modules');
addpath('./subroutines');
addpath('..');

module_list = dir('./modules/*.m');
num_modules = length(module_list);

failed_tests = 0;

for i=1:num_modules
	module_name = module_list(i).name;
	module_shortname = module_name(1:(end-2));

	fprintf('[%s]: \n',module_shortname)

	% Module run command
	module_command = sprintf('flag = %s();',module_shortname);
	eval(module_command);

	if flag
		fprintf('[%s]: Pass\n\n',module_shortname);
	else
		fprintf('[%s]: ***FAIL***\n\n',module_shortname);
	end

	failed_tests = failed_tests + ~flag;
end

fprintf('=========================\n');
fprintf('Modules Failed: %d\n',failed_tests);
fprintf('=========================\n');