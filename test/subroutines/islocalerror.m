function localerror = islocalerror(err)
% localerror = islocalerror(err)
%  This funciton takes a Matlab error struct as an input and determines if it belongs
%  to the of NRS Classifier related errors defined in the NRSErrors cell strucutre.
%
%  This file must be updated as more errors are added to different functions in the 
%  package. An interesting avenue might be to make a script which scrapes out defined
%  error calls from all the files in the repository and stores them in a single file
%  which may be checked from here. Seems a bit much, bit then it would be automated!

NRSErrors = {'nrs_classifier:UnsupportedBiasType'};

localerror = sum(cell2mat(strfind(NRSErrors,err.identifier)));

if localerror > 0
	localerror = 1;
end

localerror = logical(localerror);