function M = updateModelHV(M,prevH,maxQHV,actionHV,gamma,alpha,R)
    % Function updates the model hypervectors
    q_true = R + gamma * maxQHV;
    q_pred = similarity(prevH,M(actionHV));
    regError = q_true - q_pred;
    M(actionHV).samples = M(actionHV).samples + alpha * regError * prevH.samples;
   % M(actionHV) = M(actionHV).normalize; % DEBUG
end