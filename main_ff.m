function main_ff(J, M1, M2, P1, P2, P3, P4)      
    
    % Initializations
    MAX_EPISODES = 1000;
    performanceTelem = nan(1,MAX_EPISODES);
    maxVal = [4.8, .5, deg2rad(24), deg2rad(50)];            % [meters, m/s, rad, rad/s]
    minVal = [-4.8, -.5, -deg2rad(24), -deg2rad(50)];      % [meters, m/s, rad, rad/s]
    epsilon = 0;                                                             % probability of random action
    M = [M1,M2];                                                           % make model HV easy to index
    failures = 0;
 
        while (failures < MAX_EPISODES)                             % Episode loop

            % Initialize episode
            steps = 0;
            state = resetState(true);                                  % true = use small random initial state
            doneHV = false; 
            [H,~] = encodeStateHV_orig(state, J, P1, P2, ...
                P3, P4, maxVal, minVal, J);

            while ~doneHV                                                                                                    
                
                steps = steps + 1;                                                       % increment steps     
                action = selectActionHV(H,M(1),M(2),epsilon);
                
                % Original encoding
                [newState, doneHV] = takeAction(action, state);             % apply action to the cart-pole         
                
                % Delta encoding
                delta = newState - state;
                [H,~] = encodeStateHV_delta(delta, H, P1, P2, ...
                                    P3, P4, maxVal, minVal);
  
               state = newState;
                
            end % while ~doneHV 

            failures = failures + 1;
            performanceTelem(failures) = steps;                          % record num steps for this iteration

           if (mod(failures,10)==0)
                disp(failures)
           end

        end % while (failures < MAX_EPISODES)    

    assignin('base','performanceTelem',performanceTelem)
    figure(1);plot(1:failures,performanceTelem(1:failures),'rx-','LineWidth',2)

end % function