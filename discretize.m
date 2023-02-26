function discreteState = discretize(maxValues, minValues, qTable, observation)

    sizeTable = size(qTable());
    amtPerBin = (maxValues - minValues) ./ sizeTable(1:4);
    discreteState = round((observation - minValues) ./ amtPerBin);
    discreteState = max([discreteState; ones(1,4)]);
    discreteState = min([discreteState; sizeTable(1:4)]);
    
end