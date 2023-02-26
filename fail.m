function trialFail = fail(state)

    if ( state(3) < -deg2rad(12) || state(3) > deg2rad(12) ||  state(1) < -2.4 || state(1) > 2.4 )
                  trialFail = true;  
       else
                  trialFail = false;
    end

end % function

