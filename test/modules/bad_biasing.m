function passed = bad_biasing()
% bad_biasing.m
%
% The bad_biasing module will check and make sure that a proper error is thrown
% when an improper biasing call is made.
passed = 1;

%% Dummy Data Run
T = 20;   % Number of training and testing samples
D = 5;    % Number of features
l = 1;    % Regularization parameter, lambda

% Incorrect biasing term
L = cell(1,2);
L{1} = randn(D);
L{2} = randn(D);

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

% Reverse this because we want to make sure that the error was
% thrown.
passed = ~passed;

