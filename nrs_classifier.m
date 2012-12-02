function [assignments prox] = nrs_classifier(Train,Test,Train_labels,lambda,bias)
% nrs_classifier(Train,Test,Train_labels,params)
%    Use Nearest Regularized Subspace method to classify the provided test samples
%    based upon the given training set.
%
% Inputs:
%       * Train             -- Training data matrix (Ntrain x d)
%       * Test              -- Testing data matrix (Ntest x d)
%       * Train_labels      -- Class labels of the training dataset (Classes x 1)
%       * lambda            -- Regularization parameter (scalar)
%       * bias              -- [Optional] Allows the user to specify how to calculate
%                              the biasing factors in the matrix \Gamma. Can take the
%                              form of a transform matrix (f x d) or function handle.
%                                > If chosen to be a function handle, the function must
%                                  take two (1 x d) vector inputs and calculate a scalar
%                                  value result.
%                              Default: Euclidean distance in feature space. 
% Outputs:
%       * assignments       -- Class labels assigned to each of the test samples (Ntest x 1)
%

Train=Train'; Test=Test';

[features NTrain] = size(Train);
[features2 NTest] = size(Test);
NClasses = length(Train_labels);    
approx_acc = zeros(NClasses,NTest); % Buffer to hold approximation accuracies

%% Data Check
if features ~= features2
    error('nrs_classifier:DimensionMismatch','The feature dimensionality of the Training and Test sets are different!');
end

if ~isreal([Train Test])
    error('nrs_classifier:ComplexData','Complex data types are currently unsupported.');
end

%% Bias Check
% Determine which kind of biasing the user wants to use when constructing 
% the Tikhonov matrix, \Gamma.
if nargin > 4
    if isa(bias,'function_handle')
        biasing = @(A,B,l,b) kernel_biasing(A,B,l,b);
    else
        if ~isscalar(bias)
            if ~iscell(bias)
                biasing = @(A,B,l,b) matrix_biasing(A,B,l,b);
            else
                error('nrs_classifier:UnsupportedBiasType','Bias input format is unsupported!');
            end
        else
            error('nrs_classifier:UnsupportedBiasType','Bias input format is unsupported!');
        end    
    end
else
    bias = [];
    biasing = @(A,B,l,b) default_biasing(A,B,l);
end

%% Label Check
% Make sure that the training labels are in the expected format. The label
% vector should consist of C entries, where C is the number of classes and 
% each entry specifies how many of the training samples belong to the class
% at that index.
if NClasses == NTrain
	% In this case, there is a training label assigned to every sample.
	% We will reorganize the training set according to the given labels.
	[sorted_labels ordering] = sort(Train_labels,'ascend');
	Train = Train(:,ordering);
	Train_labels = hist(sorted_labels,unique(sorted_labels));
	NClasses = length(Train_labels);
end

%% Pre-calculate Class Covariance Matrices
Sigma = cell(1,NClasses);
first = 1;
for c=1:NClasses
	last = first + Train_labels(c)-1;	
    Sigma{c} = Train(:,first:last)'*Train(:,first:last);     
	first = last+1;
end

%% Main Loop
% The classifier needs to find an approximation for each test sample for
% each class. So, the number of approximations is of order O(NClasses*NTest).
% The downside of this approach, computationally, is that the inverse of a
% (Ntrain x Ntrain) matrix must be computed O(NClasses*NTest) times, though
% perhaps not explicitly (\ operator).
first = 1;
for c=1:NClasses
    fprintf('%d/%d, ',c,NClasses);
    last = first+ Train_labels(c)-1;
    ClassTrain = Train(:,first:last);

    % Calclate all biasings for this class's training samples against
    % all test samples.
    BC = biasing(ClassTrain,Test,lambda,bias);  


    % Now, for every test sample we have to calculate an approximation
    for t=1:NTest
        tsamp = Test(:,t);          
        G = diag(BC(:,t));
        
        weights = (Sigma{c}+G)\(ClassTrain'*tsamp);

        approx = ClassTrain*weights;
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

function BiasCorrsp = kernel_biasing(DTrain,DTest,lambda,bias)
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





