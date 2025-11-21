function lag_nanmedians=nocgliders_oxygen_plot_lag(oxygen_lags, N, areas, oxygen_shifts)

close all
tmp.vars={'UPvsDOWN','DOWNvsUP','UPvsDOWN_and_DOWNvsUP','UPvsDOWN_and_DOWNvsUP_500m'};
% areas=[200,100,50];
c=[rgb('firebrick'); rgb('teal');rgb('gold')];

m=nan(4,length(areas)+1);

for i=1:4 % methods
    for j=1:length(areas)
        subplot(4,length(areas),i*length(areas)-(length(areas)-1));
        hh=histogram(oxygen_lags.(tmp.vars{i})(:,1),N);
        set(hh, 'facecolor', 'k')
        title([(tmp.vars{i}) ' (all) = ' num2str(nanmedian(oxygen_lags.(tmp.vars{i})(:,1)))], 'interpreter', 'none')
        grid on; box on
        vl=vline(nanmedian(oxygen_lags.(tmp.vars{i})(:,1)));
        set(vl, 'color', 'k', 'linewidth', 2)
        

        subplot(4,length(areas),i*length(areas)-(length(areas)-2)); hold on
        v=oxygen_lags.(tmp.vars{i});
        v(v(:,1)<=nanmin(oxygen_shifts),2)=nan;
        h(j)=histogram(v(v(:,2)<areas(j),1),N);
        set(h(j), 'facecolor', c(:,j));
        title([(tmp.vars{i}) ' (area<X)'], 'interpreter', 'none')
        grid on; box on
        vl=vline(nanmedian(v(v(:,2)<areas(j),1)));
        set(vl, 'color', c(:,j), 'linewidth', 2)
        m(i,j+1)=nanmedian(v(v(:,2)<areas(j),1));
%         legend([h(1),h(2),h(3)], {['area<' num2str(areas(1)) ' = ' num2str(m(1,i))], ...
%             ['area<' num2str(areas(2)) ' = ' num2str(m(2,i))],['area<' num2str(areas(3)) ' = ' num2str(m(3,i))]})

        if j==length(areas)
            subplot(4,length(areas),i*length(areas));
            v=oxygen_lags.(tmp.vars{i});
            v(v(:,1)<=nanmin(oxygen_shifts),2)=nan;
            h(length(areas)+1)=histogram(v(v(:,2)<areas(j),1),N);
            set(h(length(areas)+1), 'facecolor', c(:,j));
            
            title([(tmp.vars{i}) ' (area<' num2str(areas(j))  ') = ' num2str(m(1))], 'interpreter', 'none')
            grid on; box on
            vl=vline(nanmedian(v(v(:,2)<areas(j),1)));
            set(vl, 'color', c(:,j), 'linewidth', 2)
        end
        
    end
    m(i,1)=nanmedian(oxygen_lags.(tmp.vars{i})(:,1));
end

lag_nanmedians=array2table(m, 'RowNames', (cellstr(tmp.vars)), ...
    'VariableNames', {'all areas',['area<' num2str(areas(1))], ...
    ['area<' num2str(areas(2))],['area<' num2str(areas(3))]});

% % legend([h(1),h(2),h(3)], {['area<X(' num2str(X(1))],['area<X(' num2str(X(2))],['area<X(' num2str(X(3))]})
% 
% %     
% % X=200;
% % for i=1:4
% % 
% %     subplot(4,2,i*2); hold on
% %     v=oxygen_lags.(tmp.vars{i});
% %     h2=histogram(v(v(:,2)<X,1),100);
% %     title([(tmp.vars{i}) ' (area<' num2str(X) ')'], 'interpreter', 'none')
% % end
% % 
% % X=100;
% % for i=1:4
% % 
% %     subplot(4,2,i*2); hold on
% %     v=oxygen_lags.(tmp.vars{i});
% %     h3=histogram(v(v(:,2)<X,1),100);
% %     title([(tmp.vars{i}) ' (area<X)'], 'interpreter', 'none')
% % end
% 
% % legend([h1,h2,h3], {'area<500','area<200','area<100'})
% %%
% tmp.vars={'UPvsDOWN','DOWNvsUP','UPvsDOWN_and_DOWNvsUP','UPvsDOWN_and_DOWNvsUP_500m'};
% for i=1:4
%     subplot(4,1,i);
% %     histogram(oxygen_lags.(tmp.vars{i})(:,1),100);
% %     title([(tmp.vars{i}) ' (all)'], 'interpreter', 'none')
% 
%     hold on;
%     v=oxygen_lags.(tmp.vars{i});
%     histogram(v(v(:,2)<100,1),100);
%     title([(tmp.vars{i}) ' (area<' num2str(X) ')'], 'interpreter', 'none')
% end
% 
% % v=oxygen_lags.(tmp.vars{i});
% % hist(aa(aa(:,2)<15,1),100)