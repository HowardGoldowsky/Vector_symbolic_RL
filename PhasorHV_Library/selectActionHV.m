function action = selectActionHV(H,M1,M2,epsilon)
    if (rand < epsilon)                                         
            action = round(rand)+1;
    else    
        [~, action] = max([similarity(H,M1),similarity(H,M2)]);
    end
end

