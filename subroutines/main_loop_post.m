function scores = main_loop_post(Train,Test,Train_labels,lambda,biasing,ranking)
NClasses = length(Train_labels);
NTest = size(Test,2);
NTrain = size(Train,2);
weights = zeros(NTrain,NTest);
scores = zeros(NClasses,NTest);

%% Pre-calculations
Sigma = Train'*Train;
BC = biasing(Train,Test,lambda);
TrainTTest = Train'*Test;

%% Main Loop
% The classifier needs to find an approximation for each test sample for
% each class. So, the number of approximations is of order O(NClasses*NTest).
% The downside of this approach, computationally, is that the inverse of a
% (Ntrain x Ntrain) matrix must be computed O(NClasses*NTest) times, though
% perhaps not explicitly (\ operator).
for t=1:NTest
    G = spdiags(BC(:,t),0,NTrain,NTrain);
    SigG = Sigma + G;
    weights(:,t) = SigG\TrainTTest(:,t);
end

first = 1;
for c=1:NClasses
    fprintf('%d/%d, ',c,NClasses);
    last = first+ Train_labels(c)-1;
    
    approx_class = Train(:,first:last)*weights(first:last,:);
    
    % Doing the score calculation in a loop to make sure that 
    % it all works correctly, despite user input for the ranking
    % function.
    for t=1:NTest
        tsamp = Test(:,t);
        approx = approx_class(:,t);
        scores(c,t) = ranking(approx,tsamp);
    end

    first = last+1;
end
fprintf('\n');