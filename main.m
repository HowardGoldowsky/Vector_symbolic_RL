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
        epsilon = .9999; %.999;                                              % probability of random action
        epsilonDec = 0.99; % 0.95; %0.995;
        ALPHA = 0.8; % 0.85                                                   % learning rate 
        GAMMA = 0.95;                                                        % discount factor for future reinf 

        % Initialize the required hypervectors     
        D = 6000;                               % hypervector length

        H = PhasorHV(D);                    % init random state vector as zero state
        J = H;

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
            stateHV = resetState(false); % do not use rand init
     %       prevStateHV = stateHV;
            doneHV = false; 
            [H,~] = encodeStateHV_orig(stateHV, H, P1, P2, P3, P4, maxVal, minVal, J);
            prevH = H;

            while ~doneHV                                                                                                    % check for failure / complete iteration               
                steps = steps + 1;                                                                                           % increment steps     
                actionHV = selectActionHV(H,M(1),M(2),epsilon);
                [stateHV, doneHV] = takeAction(actionHV, stateHV);                                          % apply action to the cart-pole         
                H = J;                                                                                                              % reset state HV
                [H,~] = encodeStateHV_orig(stateHV, H, P1, P2, P3, P4, maxVal, minVal, J);
                [maxQHV, ~] = max([similarity(H,M(1)),similarity(H,M(2))]);

                if ~doneHV
                    R = STANDREWARD;
                else
                    R = FALLPENALTY;
                end
                M = updateModelHV(M,prevH,maxQHV,actionHV,GAMMA,ALPHA,R);

               % prevStateHV = stateHV;
               prevH = H;

            end % while ~done 

            failures = failures + 1;
            performanceTelem(run,failures) = steps;                                                            % record num steps for this iteration
            epsilon = epsilon * epsilonDec;                                                                     % exploration rate update

           if (mod(failures,WINSIZE)==0)
               % disp(run)
                disp(failures)
           end
            %meanSteps = movmean(performanceTelem(run,1:failures),WINSIZE);
            if failures >= WINSIZE
                meanSteps = mean(performanceTelem(run,failures-WINSIZE+1:failures));
            else
                meanSteps = steps;
            end
            if (meanSteps >= 200)
               break;
            end
%            end

        end % while (failures < MAX_EPISODES)    
        plotRewardHistory(performanceTelem(run,:),WINSIZE); 
        
        saveFile = sprintf('saveFile%d',run);
        save(saveFile,'M','H','J','P1','P2','P3','P4');

    end % for run
    assignin('base','performanceTelem',performanceTelem)
    figure(1);plot(movmean(mean(performanceTelem(:,1:failures),1),WINSIZE),'r-','LineWidth',2)
    
end % function