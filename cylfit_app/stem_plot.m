function stem = stem_plot(filename,offset)
    stem = load(filename);
    utm_offset = [407000 3280000];
    stem(:,1:2) = stem(:,1:2) - utm_offset;
    f = figure; f.Name = 'stem inspection';
    set(gca,'Color',[0 0 0]); grid off; axis equal;
    ax = gca; ax.GridColor = [0.9 0.9 0.9];
    title(filename,'Interpreter','none'); hold on; view(20,15);
    scatter3(stem(:,1),stem(:,2),stem(:,3)-offset,1,stem(:,3));
    colormap(cool);
    xlim([min(stem(:,1)) max(stem(:,1))])
    ylim([min(stem(:,2)) max(stem(:,2))])
    zlim([min(stem(:,3)) max(stem(:,3))] - offset)
    xticks(min(stem(:,1)):1:max(stem(:,1)))
    yticks(min(stem(:,2)):1:max(stem(:,2)))
    zticks(min(stem(:,3)):0.5:max(stem(:,3)))
    %xtickformat('%8.1f'); ytickformat('%8.1f'); ztickformat('%4.1f')
    xlabel('X [m]');ylabel('Y [m]');zlabel('hgt [m]');
    hold off;
end