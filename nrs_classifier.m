function [assignments prox] = nrs_classifier(Train,Test,Train_labels,lambda,params)
% nrs_classifier(Train,Test,Train_labels,params)
%    Use Nearest Regularized Subspace method to classify the provided test samples
%    based upon the given training set.
%
% Inputs:
%       [REQUIRED]
%       * Train             -- Training data matrix (d x NTrain)
%       * Test              -- Testing data matrix (d x NTest)
%       * Train_labels      -- Class labels of the training dataset (Classes x 1)
%       * lambda            -- Regularization parameter (scalar)
%
%       [OPTIONAL]
%       * params.bias       -- Allows the user to specify how to calculate
%                              the biasing factors in the matrix \Gamma. Can take the
%                              form of a transform matrix (f x d) or function handle.
%                                > If chosen to be a function handle, the function must
%                                  take two (1 x d) vector inputs and calculate a scalar
%                                  value result.
%                              (Default: Euclidean distance in feature space) 
%       * params.features   -- Specify the dimensionality (d) of the
%                              feature vectors used in Train and Test.
%                              Specify this parameter if you are unsure
%                              about the proper orientation of the data
%                              matrices.
%       * params.ranking    -- Specifies a
%                              function handle which takes two inputs, a
%                              class approximation and a test sample (both dx1), 
%                              and outputs a scalar value which denotes the
%                              proximity of the class approximation to the
%                              test sample. 
%                              (Default: Squared Euclidean Distance)
%       * params.ranking_dir-- Specifies which direction the ranking of class
%                              approximations should be done in.
%                                   > -1  : Minimization
%                                   > 1   : Maximization 
%                              (Default: Minimizatoin)
%       * params.partition_mode -- String specifying what kind of partitioning to
%                                  use, pre-partitioning (as in NRS paper) 
%                                  or post-partitioning (ala CRC/SRC).
%                                       > "pre"  : Pre-partitioning
%                                       > "post" : Post-partitioning
%                                  (Default: Pre-partitioning)
% Outputs:
%       * assignments       -- Class labels assigned to each of the test samples (Ntest x 1)
%

addpath('./subroutines');
[features NTrain] = size(Train);
[features2 NTest] = size(Test);
NClasses = length(Train_labels);    

%% Check passed parameters
if isfield(params,'features')
    if NTrain == params.features && features ~= params.features
        % Training set rotated incorrectly
        Train = Train';
        [features NTrain] = size(Train);
    end
    
    if NTest == params.features && features2 ~= params.features
        % Test set rotated incorrectly
        Test = Test';
        [features2 NTest] = size(Test);
    end
    
    
    if features ~= params.features
        error('nrs_classifier:DimensionMismatch','Passed feature size does not match Training set.');
    end
    
    if features2 ~= params.features
        error('nrs_classifier:DimensionMismatch','Passed feature size does not match Test set.');
    end
end

ranking_direction = -1;
if isfield(params,'ranking_dir')
    if params.ranking_dir > 0
        ranking_direction = 1;
    end
end

pre_part_mode = 1;
if isfield(params,'partition_mode')
    switch params.partition_mode
        case 'pre'
            pre_part_mode = 1;
        case 'post'
            pre_part_mode = 0;
    end
end


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
if isfield(params,'bias')
    if isa(params.bias,'function_handle')
        biasing = @(A,B,l) kernel_biasing(A,B,l,params.bias);
    else
        if ~isscalar(params.bias)
            if ~iscell(params.bias)
                biasing = @(A,B,l) matrix_biasing(A,B,l,params.bias);
            else
                error('nrs_classifier:UnsupportedBiasType','Bias input format is unsupported!');
            end
        else
            error('nrs_classifier:UnsupportedBiasType','Bias input format is unsupported!');
        end    
    end
else
    biasing = @(A,B,l) default_biasing(A,B,l);
end

%% Ranking Check
% Determine how to score all of the approximations.
if isfield(params,'ranking')
    if isa(params.ranking,'function_handle')
        ranking = params.ranking;
    else
        error('nrs_classifier:UnsupportedRankingType','Ranking must be specified as a function handle.');
    end
else
    ranking = @(x,y) default_ranking(x,y);
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

if pre_part_mode
    approx_acc = main_loop_pre(Train,Test,Train_labels,lambda,biasing,ranking);
else
    approx_acc = main_loop_post(Train,Test,Train_labels,lambda,biasing,ranking);
end

if ranking_direction < 0
    [prox assignments] = min(approx_acc);
else
    [prox assignments] = max(approx_acc);
end
