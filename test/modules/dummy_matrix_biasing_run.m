function passed = dummy_matrix_biasing_run()
% dummy_matrix_biasing_run.m
%
% Test module to run basic inputs through and verify the total opeartion of
% the classifier.
passed = 1;

%% Dummy Data Run
T = 20;   % Number of training and testing samples
D = 5;    % Number of features
l = 1;    % Regularization parameter, lambda
L = randn(D); % Biasing calculation done in transform domain specified by matrix L

DTrain = [randn(D,T) randn(D,T)+3];  % Two class training data
DTest  = [randn(D,T) randn(D,T)+3];  % Two class testing data
CTrain = [T T]; % Train labels
CTest  = [T T]; % Test labels

params.bias = L;
params.features = D;

try
[approx prox] = nrs_classifier(DTrain',DTest',CTrain,l,params);
catch err 
	if islocalerror(err)
		fprintf('  ERROR: %s\n',err.identifier);
		passed = 0;
	else
		rethrow(err);
	end
end

