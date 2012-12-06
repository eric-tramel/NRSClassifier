function score = default_ranking(approx,y)
% Default scoring of approximations based upon squared euclidean distance.
    r = approx - y;
    score = r'*r;