function main()      
    
    % Initializations
    clear all                                                                   %#ok<CLALL> % clear persistent variables
    MAX_EPISODES = 10000;
    NUMRUNS = 1;                                                     % number of runs in meta analysis
    WINSIZE = 50;                                                          % moving average window size
    performanceTelem = nan(NUMRUNS,MAX_EPISODES);
    maxVal = [4.8, .5, deg2rad(24), deg2rad(50)];            % [meters, m/s, rad, rad/s]
    minVal = [-4.8, -.5, -deg2rad(24), -deg2rad(50)];      % [meters, m/s, rad, rad/s]
    FALLPENALTY = -1;
    STANDREWARD = 0;
    
    for run = 1:NUMRUNS

        % Initialize for each run
        failures = 0;
        epsilon = .999; %.999;                                              % probability of random action
        epsilonDec = .995; %0.995;  
        ALPHA = 0.8; % 0.95 0.85                                                   % learning rate 
        alphaDec = 1;
        GAMMA = 0.95;                                                        % discount factor for future reinf 

        % Initialize the required hypervectors     
        D = 6000;                               % hypervector length

        H = PhasorHV(D);                    % init random state vector as zero state
        basisState = H;

        P1 = PhasorHV(D);                    % state hypervectors, one for each dimension of the Q-table
        P2 = PhasorHV(D);
        P3 = PhasorHV(D);
        P4 = PhasorHV(D);

        M1 = PhasorHV(D,zeros(D,1));    % model hypervectors, one for each position in the action space; init to zeros
        M2 = PhasorHV(D,zeros(D,1));
        M = [M1,M2];                            % make easy to index

        while (failures < MAX_EPISODES)   

            % HDC Cart-pole
            steps = 0;
            state = resetState(false); % do not use rand init
            doneHV = false; 
            [H,~] = encodeStateHV_delta(state, basisState, P1, P2, ...
                P3, P4, maxVal, minVal);
            prevH = H;

            while ~doneHV                                                                                                    % check for failure / complete iteration               
                steps = steps + 1;                                                                                           % increment steps     
                actionHV = selectActionHV(H,M(1),M(2),epsilon);
                [newState, doneHV] = takeAction(actionHV, state);                                          % apply action to the cart-pole   
                delta = newState - state;
                [H,~] = encodeStateHV_delta(delta, H, P1, P2, P3, P4, maxVal, minVal);
                [maxQHV, ~] = max([similarity(H,M(1)),similarity(H,M(2))]);

                if ~doneHV
                    R = STANDREWARD;
                else
                    R = FALLPENALTY;
                end

                M = updateModelHV(M,prevH,maxQHV,actionHV,GAMMA,ALPHA,R);
                prevH = H;
                state = newState;
                
            end % while ~done 

            failures = failures + 1;
            performanceTelem(run,failures) = steps;                                                            % record num steps for this iteration
            epsilon = epsilon * epsilonDec;                                                                     % exploration rate update
            ALPHA = ALPHA * alphaDec;

            if (mod(failures,WINSIZE)==0)
                disp(failures)
            end
            
            if failures >= WINSIZE
                meanSteps = mean(performanceTelem(run,failures-WINSIZE+1:failures));
            else
                meanSteps = steps;
            end
            
            if (meanSteps >= 500)
               break;
            end

        end % while (failures < MAX_EPISODES)    
        plotRewardHistory(performanceTelem(run,:),WINSIZE); 
        
        saveFile = sprintf('saveFile%d',run);
        save(saveFile,'M','H','basisState','P1','P2','P3','P4');

    end % for run
    assignin('base','performanceTelem',performanceTelem)
    figure(1);plot(movmean(mean(performanceTelem(:,1:failures),1),WINSIZE),'r-','LineWidth',2)
    
end % function