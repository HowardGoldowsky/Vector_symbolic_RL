function plotRewardHistory(performanceTelem,WINSIZE)    

    figure(1); hold on
    
    plot(1:length(performanceTelem),movmean(performanceTelem,WINSIZE),'b-','LineWidth',1);
    xlabel('\bf Episode Number');
    ylabel('\bf Number of Steps');
    title('\bf Cart-pole Steps vs. Trial Number');
    
%     figure;
%     plot((1:length(regErrorTelem)),movmean(regErrorTelem,WINSIZE),'b-','LineWidth',1);
%     xlabel('\bf Episode Number');
%     ylabel('\bf Regression Error');
%     title('\bf Regression Error vs. Trial Number');

end