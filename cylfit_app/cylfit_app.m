% check if working directory is correct
fprintf(' - Current directory:\n     %s\n',cd);
check = input(' - Is this correct? [y/n]: ','s');
if check == 'n'
    % prompt for working directory if not
    cd_ = input(' - Directory: ','s');
    cd(cd_);
end 

% prompt to name the output file
outfile = input(' - Output file name [.out assumed]: ','s');

segment = 0.1; % height of cylinder segment to plot

% get list of names of all text files in folder
% these should be n x 4 arrays of the trees
listing = dir;
names = cell(length(listing),1);
headerRow(outfile);
for ii = 1:length(listing)
    if endsWith(listing(ii).name,'.txt') == 1
        names(ii) = {listing(ii).name};
    end
    names = names(~cellfun(@isempty,names));
end

% this loop runs for each text file in the list generated above
for ii = 1:length(names)
    % display stem filename in command window
    fprintf('\n---%s---\n',names{ii})
    % load contents of stem file into an array
    stem = load(names{ii});
    % calculate mean Z of ground
    ind = (stem(:,4) == min(stem(:,4))); % ind is a logical array
    % calculate mean Z of all pts with lowest hgt above ground
    mean_z_min = mean(stem(ind,3)); 
    % initialize array to append to outfile
    out = [];
    
    % low (close to ground)
    flag = false;
    while ~flag
        keep = 'n';
        while keep ~= 'y'
            stem_plot(names{ii},mean_z_min); view(0,0)
            hi = validNumericInput(' - low height (close to ground): ');
            zlim([hi-0.05 hi+0.05]); view(0,90);
            keep = input(' - keep this height? [y/n]: ','s');
        end
        cod = input(' - multiple stems? [y/n]: ','s');
        if cod == 'n'
            box = selectStem(hi);
            stem_ = stemFilter(stem,box,hi,mean_z_min);
            stem_ = stem_ - [0 0 mean_z_min 0];
            hold on; scatter3(stem_(:,1),stem_(:,2),stem_(:,3),6,'k');
            flag2 = false;
            while ~flag2
                out_pct = validNumericInput(' - Outlier % [0-1]: ');
                results = cylfit_ransac_fast(stem_(:,1:3),out_pct,10);
                out = [out;results];
                hold on; plotCylinder(results,segment);
                fprintf(' - Diameter [cm] = %.1f\n',100*results(7))
                check = input(' - Accept results? [y/n]: ','s');
                if check == 'y'
                    recordResults(outfile,names{ii},hi,results);
                    flag2 = true;
                else
                    stem_plot(names{ii},mean_z_min);
                    hold on; scatter3(stem_(:,1),stem_(:,2),stem_(:,3),6,'k');
                end
            end
            flag = true;
        elseif cod == 'y'
            zlim([hi hi+0.09]); view(0,90);
            n_rects = validNumericInput(' - Number of codominant stems: ');
            for jj = 1:n_rects
                fprintf('\n---Box %d---\n',jj)
                box = selectStem(hi);
                stem_ = stemFilter(stem,box,hi,mean_z_min);
                stem_ = stem_ - [0 0 mean_z_min 0];
                hold on; scatter3(stem_(:,1),stem_(:,2),stem_(:,3),6,'k');
                flag3 = false;
                while ~flag3
                    out_pct = validNumericInput(' - Outlier % [0-1]: ');
                    results = cylfit_ransac_fast(stem_(:,1:3),out_pct,10);
                    out = [out;results];
                    hold on; plotCylinder(results,segment);
                    fprintf(' - Diameter [cm] = %.1f\n',100*results(7))
                    check = input(' - Accept results? [y/n]: ','s');
                    if check == 'y'
                        recordResults(outfile,names{ii},hi,results);
                        flag3 = true;
                    else
                        stem_plot(names{ii},mean_z_min);
                        hold on; scatter3(stem_(:,1),stem_(:,2),stem_(:,3),6,'k');
                    end
                end            
            end         
            flag = true;
        end
    end
    
    % DBH: 1.4 m
    flag = false;
    while ~flag
        keep = 'n';
        while keep ~= 'y'
            stem_plot(names{ii},mean_z_min); view(0,0)
            hi = validNumericInput(' - DBH height (1.4 m recommended): ');
            zlim([hi-0.05 hi+0.05]); view(0,90);
            keep = input(' - keep this height? [y/n]: ','s');
        end
        cod = input(' - multiple stems? [y/n]: ','s');
        if cod == 'n'
            box = selectStem(hi);
            stem_ = stemFilter(stem,box,hi,mean_z_min);
            stem_ = stem_ - [0 0 mean_z_min 0];
            hold on; scatter3(stem_(:,1),stem_(:,2),stem_(:,3),6,'k');
            flag2 = false;
            while ~flag2
                out_pct = validNumericInput(' - Outlier % [0-1]: ');
                results = cylfit_ransac_fast(stem_(:,1:3),out_pct,10);
                out = [out;results];
                hold on; plotCylinder(results,segment);
                fprintf(' - Diameter [cm] = %.1f\n',100*results(7))
                check = input(' - Accept results? [y/n]: ','s');
                if check == 'y'
                    recordResults(outfile,names{ii},hi,results);
                    flag2 = true;
                else
                    stem_plot(names{ii},mean_z_min);
                    hold on; scatter3(stem_(:,1),stem_(:,2),stem_(:,3),6,'k');
                end
            end
            flag = true;
        elseif cod == 'y'
            zlim([hi hi+0.09]); view(0,90);
            n_rects = validNumericInput(' - Number of codominant stems: ');
            for jj = 1:n_rects
                fprintf('\n---Box %d---\n',jj)
                box = selectStem(hi);
                stem_ = stemFilter(stem,box,hi,mean_z_min);
                stem_ = stem_ - [0 0 mean_z_min 0];
                hold on; scatter3(stem_(:,1),stem_(:,2),stem_(:,3),6,'k');
                flag3 = false;
                while ~flag3
                    out_pct = validNumericInput(' - Outlier % [0-1]: ');
                    results = cylfit_ransac_fast(stem_(:,1:3),out_pct,10);
                    out = [out;results];
                    hold on; plotCylinder(results,segment);
                    fprintf(' - Diameter [cm] = %.1f\n',100*results(7))
                    check = input(' - Accept results? [y/n]: ','s');
                    if check == 'y'
                        recordResults(outfile,names{ii},hi,results);
                        flag3 = true;
                    else
                        stem_plot(names{ii},mean_z_min);
                        hold on; scatter3(stem_(:,1),stem_(:,2),stem_(:,3),6,'k');
                    end
                end            
            end         
            flag = true;
        end
    end
    
    % high: 2.44 m

    flag = false;
    while ~flag
        keep = 'n';
        while keep ~= 'y'
            stem_plot(names{ii},mean_z_min); view(0,0)
            hi = validNumericInput(' - high height (2.44 m recommended): ');
            zlim([hi-0.05 hi+0.05]); view(0,90);
            keep = input(' - keep this height? [y/n]: ','s');
        end
        cod = input(' - multiple stems? [y/n]: ','s');
        if cod == 'n'
            box = selectStem(hi);
            stem_ = stemFilter(stem,box,hi,mean_z_min);
            stem_ = stem_ - [0 0 mean_z_min 0];
            hold on; scatter3(stem_(:,1),stem_(:,2),stem_(:,3),6,'k');
            flag2 = false;
            while ~flag2
                out_pct = validNumericInput(' - Outlier % [0-1]: ');
                results = cylfit_ransac_fast(stem_(:,1:3),out_pct,10);
                out = [out;results];
                hold on; plotCylinder(results,segment);
                fprintf(' - Diameter [cm] = %.1f\n',100*results(7))
                check = input(' - Accept results? [y/n]: ','s');
                if check == 'y'
                    recordResults(outfile,names{ii},hi,results);
                    flag2 = true;
                else
                    stem_plot(names{ii},mean_z_min);
                    hold on; scatter3(stem_(:,1),stem_(:,2),stem_(:,3),6,'k');
                end
            end
            flag = true;
        elseif cod == 'y'
            zlim([hi hi+0.09]); view(0,90);
            n_rects = validNumericInput(' - Number of codominant stems: ');
            for jj = 1:n_rects
                fprintf('\n---Box %d---\n',jj)
                box = selectStem(hi);
                stem_ = stemFilter(stem,box,hi,mean_z_min);
                stem_ = stem_ - [0 0 mean_z_min 0];
                hold on; scatter3(stem_(:,1),stem_(:,2),stem_(:,3),6,'k');
                flag3 = false;
                while ~flag3
                    out_pct = validNumericInput(' - Outlier % [0-1]: ');
                    results = cylfit_ransac_fast(stem_(:,1:3),out_pct,10);
                    out = [out;results];
                    hold on; plotCylinder(results,segment);
                    fprintf(' - Diameter [cm] = %.1f\n',100*results(7))
                    check = input(' - Accept results? [y/n]: ','s');
                    if check == 'y'
                        recordResults(outfile,names{ii},hi,results);
                        flag3 = true;
                    else
                        stem_plot(names{ii},mean_z_min);
                        hold on; scatter3(stem_(:,1),stem_(:,2),stem_(:,3),6,'k');
                    end
                end            
            end         
            flag = true;
        end
    end
    
    % write results to outfile
    stemReport(outfile,out);
    
end


function stem = stem_plot(filename,offset)
    stem = load(filename);
    figure(99); clf(99); f = gcf; f.Name = 'stem measure app';
    set(gca,'Color',[0.2 0.2 0.2]); grid on; axis equal;
    ax = gca; ax.GridColor = [0.9 0.9 0.9];
    title(filename,'Interpreter','none'); hold on; view(20,15);
    scatter3(stem(:,1),stem(:,2),stem(:,3)-offset,1,stem(:,3));
    colormap(cool);
    xlim([min(stem(:,1)) max(stem(:,1))])
    ylim([min(stem(:,2)) max(stem(:,2))])
    zlim([min(stem(:,3)) max(stem(:,3))] - offset)
    xticks(min(stem(:,1)):0.5:max(stem(:,1)))
    yticks(min(stem(:,2)):0.5:max(stem(:,2)))
    zticks(min(stem(:,4))*0.1:0.5:max(stem(:,3)))
    xtickformat('%8.1f'); ytickformat('%8.1f'); ztickformat('%4.1f')
    xlabel('X [m]');ylabel('Y [m]');zlabel('hgt above ground [m]');
    hold off;
end

function user_input = validNumericInput(prompt)
    flag = false;
    while ~flag
        user_input = input(prompt);
        if isnumeric(user_input)
            flag = true;
        end
    end
end

function box = selectStem(height)
    zlim([height-0.05 height+0.05]); view(0,90);
    fprintf(' - Selection box: click and drag...\n')
    flag = false;
    while ~flag
        box = getrect; % getREKT lmao
        hold on; plotBox(box,height)
        check = input(' - Keep box? [y/n]: ','s');
        if check == 'y'
            flag = true;
        else
            fprintf(' - Try again.\n')
        end
    end
end

function stem_out = stemFilter(stem_in,box_in,z,offset)
    ind = find( stem_in(:,1) < box_in(1) ...
        | stem_in(:,1) > box_in(1) + box_in(3) ...
        | stem_in(:,2) < box_in(2) ...
        | stem_in(:,2) > box_in(2) + box_in(4) ...
        | stem_in(:,3) < z + offset - 0.05 ...
        | stem_in(:,3) > z + offset + 0.05);
    stem_in(ind,:) = [];
    stem_out = stem_in;
    clear stem_in
end

function plotBox(box_in,z)
    points = [box_in(1) box_in(2) z;
    box_in(1) box_in(2)+box_in(4) z;
    box_in(1)+box_in(3) box_in(2)+box_in(4) z;
    box_in(1)+box_in(3) box_in(2) z;
    box_in(1) box_in(2) z];
    plot3(points(:,1),points(:,2),points(:,3))
end

function plotCylinder(best,segment)
    % top and bottom points of axis of plotted cylinder
    
    segment_height = segment/2; % height of slice divided by 2
    top = best(1:3) + segment_height*best(4:6);
    bot = best(1:3) - segment_height*best(4:6);
    rad = best(7)/2; % need radius
    
    % zoom to cylinder
    view(20,15); zlim([bot(3)-0.5 top(3)+0.5]);
    
    params = [top bot rad];
    model = cylinderModel(params);
    
    plot(model)
end

function headerRow(filename)
    fid = fopen([filename '.out'],'a'); % open file for appending
    fprintf(fid,'STEM       HAG     X          Y         Z     VX     VY     VZ     DIA    UNC     CONV\n');
    fclose(fid);                     % close text file
end

function recordResults(filename,stem_name,height,results)
    fid = fopen([filename '.out'],'a'); % open file for appending
    % stem_name height X Y Z ax ay az DBH unc_r conv
    % format string for text file
    str = '%10s %3.1f %10.3f %10.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.6f %3.0f\n';
    % create cell array of names and results
    fprintf(fid,str,stem_name,height,results);
    fclose(fid);                     % close text file
end

function stemReport(filename,results)
% STEMREPORT calculates stem parameters and produces formatted output to 
%   append to ASCII output file.

    % calculating lean
    % first: pick the biggest stem if multiple stems present
    maximums = max(round(results,1)); % find max values for each rounded column 
    ind = (round(results(:,3),1)) == maximums(3); % indices of rows with max HAG
    top_candidates = sortrows(results(ind,:),7,'descend');
    % top minus bottom
    top = top_candidates(1,:);
    vec = top(1:3) - results(1,1:3);
    lean = atan2d(sqrt(vec(1)^2 + vec(2)^2), vec(3));
    dir = mod(atan2d(vec(1), vec(2)),360);
    % weighted centroid method
    r2 = (0.5*top_candidates(:,7)).^2;
    M = sum(r2);
    Mx = sum(r2.*top_candidates(:,1))/M;
    My = sum(r2.*top_candidates(:,2))/M;
    Mz = sum(r2.*top_candidates(:,3))/M;
    top_c = [Mx My Mz];
    vec_c = top_c - results(1,1:3);
    lean_c = atan2d(sqrt(vec_c(1)^2 + vec_c(2)^2), vec_c(3));
    dir_c = mod(atan2d(vec_c(1), vec_c(2)),360);
    % write results
    fid = fopen([filename '.out'],'a'); % open file for appending   
    fprintf(fid,'-----\n');
    fprintf(fid,'         DBH: %.1f cm\n',results(2,7)*100);
    fprintf(fid,'        Lean: %.0f°\n',lean);
    fprintf(fid,'     Azimuth: %.0f°\n',dir);
    fprintf(fid,'     WC Lean: %.0f°\n',lean_c);
    fprintf(fid,'  WC Azimuth: %.0f°\n',dir_c);
    fprintf(fid,'-----\n\n');
    fclose(fid);
end