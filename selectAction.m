function action = selectAction(qTable, dState, epsilon)
    if (rand < epsilon)                                         
        action = round(rand)+1;
    else
        if qTable(dState(1),dState(2),dState(3),dState(4),1) <= qTable(dState(1),dState(2),dState(3),dState(4),2)
            action = 2;
        else
            action = 1;
        end
    end  
end  % function
