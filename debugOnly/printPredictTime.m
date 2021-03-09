function printPredictTime(predictTime)
    % predictTime = t * (totalNUM - thisNUM); % predict time in second
    if predictTime >= 3600
        fprintf("remaining %.2f hours.\n",predictTime/3600);
    elseif predictTime >= 60
        fprintf("remaining %.2f minutes.\n",predictTime/60) ;
    else
        fprintf("remaining %.2f seconds.\n",predictTime);
    end
end

