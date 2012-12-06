% An example script to demonstrate how to use the NRS classifier. For the
% LFDA portions, requires that the LFDA toolbox code 
% (available: http://sugiyama-www.cs.titech.ac.jp/~sugi/software/LFDA/)
% be in the path.
%
% LFDA code not included with this package due to licensing.
clear

addpath('../');
addpath('../subroutines');

%% Load a classification dataset.
% The provided dataset is an 8-class set taken from the Indian Pines HSI
% dataset.
load data/VegetationReducedData1500_10.mat

Normalize = max(max(max(DataTrain)),max(max(DataTest)));
DataTrain = DataTrain ./ Normalize;
DataTest = DataTest ./ Normalize;

DataTrain = DataTrain';
DataTest = DataTest';
lambda = 0.5^2;
NClasses = length(CTest);

params.features = size(DataTrain,1);

%% NRS-Pre Classification
assignments = nrs_classifier(DataTrain,DataTest,CTrain,lambda,params);

% Test accuracy
Test_labels = convert_labels(CTest,NClasses);
correct = (assignments == Test_labels);
NTest = length(assignments);
avg_accuracy = sum(correct) ./ NTest;

fprintf('[NRS-Pre] Average Accuracy: %f\n',avg_accuracy);

%% NRS-Post Classification
params.partition_mode = 'post';
assignments = nrs_classifier(DataTrain,DataTest,CTrain,lambda,params);

% Test accuracy
Test_labels = convert_labels(CTest,NClasses);
correct = (assignments == Test_labels);
NTest = length(assignments);
avg_accuracy = sum(correct) ./ NTest;

fprintf('[NRS-Post] Average Accuracy: %f\n',avg_accuracy);