function passed = kernel_biasing()
% kernel_biasing.m
%
% Test module to check that the kernel based biasing works properly.
passed = 1;

%% Dummy Data Run
T = 20;   % Number of training and testing samples
D = 5;    % Number of features
l = 1;    % Regularization parameter, lambda

L = @(a,b) rbf(a,b);

DTrain = [randn(D,T) randn(D,T)+3];  % Two class training data
DTest  = [randn(D,T) randn(D,T)+3];  % Two class testing data
CTrain = [T T]; % Train labels

try
[approx prox] = nrs_classifier(DTrain',DTest',CTrain,l,L);
catch err 
	if islocalerror(err)
		fprintf('  ERROR: %s\n',err.identifier);
		passed = 0;
	else
		rethrow(err);
	end
end

function z = rbf(x,y)
sig = 5;
z = (x-y)'*(x-y)./sig;
z = exp(-z);