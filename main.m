function main()      
    
    % Initializations
    clear all                                                                   %#ok<CLALL> % clear persistent variables
    MAX_EPISODES = 250;
    NUMRUNS = 5;                                                        % number of runs in meta analysis
    WINSIZE = 50;                                                          % moving average window size
    COPYTOTARGETEVERY = 100;                                    % copy main model to target model after each of these many episodes
    performanceTelem = nan(NUMRUNS,MAX_EPISODES);
    maxQTelem = nan(1,100*MAX_EPISODES);
    maxVal = [4.8, .5, deg2rad(24), deg2rad(50)];            % [meters, m/s, rad, rad/s]
    minVal = [-4.8, -.5, -deg2rad(24), -deg2rad(50)];      % [meters, m/s, rad, rad/s]
    FALLPENALTY = -1;
    STANDREWARD = 0;
    totalSteps = 0;
    
    for run = 1:NUMRUNS

        % Initialize for each run
        failures = 0;
        epsilon = .1; %.999;                                              % probability of random action
        epsilonDec = .9999; %0.995;  
        ALPHA = 0.1; %0.2; % 0.95 0.85                             % learning rate 
        alphaDec = 1;
        GAMMA = 0.9;                                                      % discount factor for future reinf 
        beta = .01;                                                           % target model update rate

        % Initialize the required hypervectors     
        D = 6000;                                   % hypervector length

        H = PhasorHV(D);                        % init random state vector as zero state
        basisState = H;

        P1 = PhasorHV(D);                       % state hypervectors, one for each dimension of the Q-table
        P2 = PhasorHV(D);
        P3 = PhasorHV(D);
        P4 = PhasorHV(D);

        MA1 = PhasorHV(D,zeros(D,1));       % model hypervectors, one for each position in the action space; init to zeros
        MA2 = PhasorHV(D,zeros(D,1));
        MA_main = [MA1,MA2];                  % make easy to index

        MB1 = PhasorHV(D,zeros(D,1));       % model hypervectors, one for each position in the action space; init to zeros
        MB2 = PhasorHV(D,zeros(D,1));
        MB_target = [MB1,MB2];                  % make easy to index

        while (failures < MAX_EPISODES)   

            % HDC Cart-pole
            steps = 0;
            state = resetState(true);           % false: do not use rand init
            doneHV = false; 
            [H,~] = encodeStateHV_delta(state, basisState, P1, P2, ...
                P3, P4, maxVal, minVal);
            prevH = H;                              % transfers initial encoded state to prevH

            while ~doneHV                          % check for failure / complete iteration          
                totalSteps = totalSteps + 1;
                steps = steps + 1;                 % increment steps 
               
                if (rand > 0.5)
                    DQflag = true;
                else
                    DQflag = false;
                end

                % Select action from the target model
                action = selectActionHV(H,MB_target(1),MB_target(2),epsilon);
                
                % apply action to the cart-pole   
                [newState, doneHV] = takeAction(action, state);                                          
                
                delta = newState - state;
                [H,~] = encodeStateHV_delta(delta, H, P1, P2, P3, P4, maxVal, minVal);
                
                % Clipped Double Q-learning.  “Addressing Function Approximation Error in Actor-Critic Methods” (Fujimoto et al., 2018)
                [maxQ1, ~] = max([similarity(H,MA_main(1)),similarity(H,MA_main(2))]);
                [maxQ2, ~] = max([similarity(H,MB_target(1)),similarity(H,MB_target(2))]);
                maxQ = min(maxQ1,maxQ2); 
                
                if ~doneHV
                    R = STANDREWARD;
                else
                    R = FALLPENALTY;
                end
                
                MA_main = updateModelHV(MA_main,prevH,maxQ,action,GAMMA,ALPHA,R);
                
                prevH = H;
                state = newState;
                
                maxQTelem(totalSteps) = maxQ;
                
                % Transfer model from target to the main model. This way
                % the main model remains stable and does not suffer from
                % overestimation of predicted reward. Then we use clipped
                % Double-Q learning to take the minimum maxQ, which also
                % contributes to stability. 
                MB_target(1).samples = (beta)*MA_main(1).samples + (1-beta)*MB_target(1).samples;
                MB_target(2).samples = (beta)*MA_main(2).samples + (1-beta)*MB_target(2).samples;
                
            end % while ~done 

            failures = failures + 1;
            performanceTelem(run,failures) = steps;                       % record num steps for this iteration
            epsilon = epsilon * epsilonDec;                                     % exploration rate update
            ALPHA = ALPHA * alphaDec;

            if (mod(failures,COPYTOTARGETEVERY)==0)
                disp(failures)
            end

        end % while (failures < MAX_EPISODES)    
        plotRewardHistory(performanceTelem(run,:),WINSIZE); 
        
        saveFile = sprintf('saveFile%d',run);
        save(saveFile,'MA_main','H','basisState','P1','P2','P3','P4');

    end % for run
    assignin('base','performanceTelem',performanceTelem)
    figure(1);plot(movmean(mean(performanceTelem(:,1:failures),1),WINSIZE),'r-','LineWidth',2)
    
end % function