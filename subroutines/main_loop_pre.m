function scores = main_loop_pre(Train,Test,Train_labels,lambda,biasing,ranking)
NClasses = length(Train_labels);
NTest = size(Test,2);

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
scores = zeros(NClasses,NTest); % Buffer to hold approximation accuracies
first = 1;
for c=1:NClasses
    fprintf('%d/%d, ',c,NClasses);
    last = first+ Train_labels(c)-1;
    ClassTrain = Train(:,first:last);
    NClassTrain = size(ClassTrain,2);

    % Calclate all biasings for this class's training samples against
    % all test samples.
    BC = biasing(ClassTrain,Test,lambda);  
    
    if size(BC,2) > NClassTrain
        % The biasings were pre calculated, we need to cut them down
        BC = BC(:,first:last);
    end
    
    
    ClassTrainTTest = ClassTrain'*Test;

    % Now, for every test sample we have to calculate an approximation
    for t=1:NTest
        tsamp = Test(:,t);          
        G = spdiags(BC(:,t),0,NClassTrain,NClassTrain);
        SigG = Sigma{c} + G;
        weights = SigG\ClassTrainTTest(:,t);
        approx = ClassTrain*weights;
        scores(c,t) = ranking(approx,tsamp);
    end
    first = last+1;
end
fprintf('\n');