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