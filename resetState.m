function state = resetState(useRandInit) %#ok<*INUSD>

if(useRandInit)
    state = [randn(1,4)*.01];
else
    state = [0, 0, 0, 0];
end

end % function