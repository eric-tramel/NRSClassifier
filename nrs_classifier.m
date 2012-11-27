function [assignments prox] = nrs_classifier(Train,Test,Train_labels,lambda,bias)
% nrs_classifier(Train,Test,Train_labels,params)
%    Use Nearest Regularized Subspace method to classify the provided test samples
%    based upon the given training set.
% 
% VERSION 2: This verison of the NRS classifier takes an additional input,
% a function handle which one can use to set how the biasing is set. The
% function works in the following manner.
%
%                            z = bias(x,y)
% 
% The function handle passed in should take two vector inputs and output
% one scalar. The function can calcualte this score based on any method,
% linear or nonlinear.

% TODO: Rearrange everything to be naturally inline with the data being
% arranged in rows rather than columns
Train=Train'; Test=Test';

[features NTrain] = size(Train);
[features NTest] = size(Test);

% Check the Training set class labels.
NClasses = length(Train_labels);

DEFAULT_BIAS = 0;
MATRIX_BIAS = 0;
if nargin < 5
    DEFAULT_BIAS = 1;  
else
    bias_functions = length(bias);
    if ismatrix(bias)
        MATRIX_BIAS=1;
    end
end

if NClasses == NTrain
	% In this case, there is a training label assigned to every sample.
	% We will reorganize the training set according tot he given labels.
	[sorted_labels ordering] = sort(Train_labels,'ascend');
	Train = Train(:,ordering);
	Train_labels = hist(sorted_labels,unique(sorted_labels));
	NClasses = length(Train_labels);
end

% Define the output variables
approx_acc = zeros(NClasses,NTest);

% Square lambda entries
sqlambda = lambda.^2;

% Pre-calculate Class Covariance Matrices
Sigma = cell(1,NClasses);
first = 1;
for c=1:NClasses
	last = first + Train_labels(c)-1;	
    Sigma{c} = Train(:,first:last)'*Train(:,first:last);     
	first = last+1;
end



% Calculate approximations for the testing set for each class
% and for each trail.
first = 1;
for c=1:NClasses
    fprintf('%d/%d, ',c,NClasses);
    last = first+ Train_labels(c)-1;
    H = Train(:,first:last);
    
    if DEFAULT_BIAS
        BC = default_biasing(H,Test,sqlambda);
    else
            if MATRIX_BIAS == 1
                BC = matrix_biasing(H,Test,sqlambda,bias);
            end
    end
    % Now, for every test sample we have to calculate an approximation
    for t=1:NTest
        tsamp = Test(:,t);          

        G = diag(BC(:,t));
        weights = (Sigma{c}+G)\(H'*tsamp);

        approx = H*weights;
        r = approx(:) - tsamp(:);
        approx_acc(c,t) = r'*r;
    end
    first = last+1;
end
fprintf('\n');

[prox assignments] = min(approx_acc);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Helper Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function BiasCorrsp = default_biasing(DTrain,DTest,lambda)
% For the sake of simplicity at the moment, we'll do this
% the slow way. 
NTrain = size(DTrain,2);
NTest = size(DTest,2);
BiasCorrsp = zeros(NTrain,NTest);

% We want to iterate through the smaller dimension
if NTest > NTrain
    for i = 1:NTrain
        tsamp = DTrain(:,i);
        diff = bsxfun(@minus,DTest,tsamp); 
        BiasCorrsp(i,:) = lambda.*sum(diff.^2);
    end
else
    for i = 1:NTest
        tsamp = DTest(:,i);
        diff = bsxfun(@minus,DTrain,tsamp); 
        BiasCorrsp(:,i) = lambda.*sum(diff.^2);
    end
end
    
function BiasCorrsp = matrix_biasing(DTrain,DTest,lambda,L)
% For the sake of simplicity at the moment, we'll do this
% the slow way. 
DTrain = (L'*DTrain);
DTest = (L'*DTest);
NTrain = size(DTrain,2);
NTest = size(DTest,2);
BiasCorrsp = zeros(NTrain,NTest);

% We want to iterate through the smaller dimension
if NTest > NTrain
    for i = 1:NTrain
        tsamp = DTrain(:,i);
        diff = bsxfun(@minus,DTest,tsamp); 
        BiasCorrsp(i,:) = lambda.*sum(diff.^2);
    end
else
    for i = 1:NTest
        tsamp = DTest(:,i);
        diff = bsxfun(@minus,DTrain,tsamp); 
        BiasCorrsp(:,i) = lambda.*sum(diff.^2);
    end
end

function BiasCorrsp = calculate_biasing(DTrain,DTest,lambda,bias)
% For the sake of simplicity at the moment, we'll do this
% the slow way. 
NTrain = size(DTrain,2);
NTest = size(DTest,2);
BiasCorrsp = zeros(NTrain,NTest);

% Note, in this version, since we are using a function handle to calcualte
% the biasing, this function might take a very long time. Perhaps this
% function can be passed in as a handle allow for more efficient batch
% processing to be specified by the user.
for i=1:NTest
    test = DTest(:,i);
    for j=1:NTrain
        train = DTrain(:,j);
        
        BiasCorrsp(j,i) = lambda.*bias(test(:),train(:));
    end
end





