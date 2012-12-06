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