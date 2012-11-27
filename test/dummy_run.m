% dummy_run.m
%
% Test module to run basic inputs through and verify the total opeartion of
% the classifier.

fprintf('Basic Functionality Test Module:\n');

%% Dummy Data Run
T = 20;   % Number of training and testing samples
D = 5;    % Number of features
l = 1;    % Regularization parameter, lambda
DTrain = [randn(D,T) randn(D,T)+3];  % Two class training data
DTest  = [randn(D,T) randn(D,T)+3];  % Two class testing data
CTrain = [T T]; % Train labels
CTest  = [T T]; % Test labels

[approx prox] = nrs_classifier(DTrain',DTest',CTrain,l);