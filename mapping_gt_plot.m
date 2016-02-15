%clear all
close all;



for k = 1:2
    if (k == 1) DestGT = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\mapping_noheaders.txt'; end
    if (k == 2) DestGT = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\boarder.txt'; end
    fileID = fopen(DestGT);
    
    C = textscan(fileID, '%s %s %8s %d %d %d %d %d %f  %f %d %d %d %d %d %d %d %d %d');
    fclose(fileID);
    
    M = C(9:10);
    M = cell2mat(M);
    horz_pct = M(:, 1);
    vert_pct = M(:, 2);
    if (k == 1)
        minh = min(horz_pct);
        maxh = max(horz_pct);
        minv = min(vert_pct);
        maxv = max(vert_pct);
    else
        if (minh > min(horz_pct)); minh = min(horz_pct); end
        if (maxh < max(horz_pct)); maxh = max(horz_pct); end
        if (minv > min(vert_pct)); minv = min(vert_pct); end
        if (maxv < max(vert_pct)); maxv = max(vert_pct); end
    end
end

for k = 1:2
    if (k == 1) DestGT = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\mapping_noheaders.txt'; end
    if (k == 2) DestGT = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\boarder.txt'; end
    fileID = fopen(DestGT);
    
    C = textscan(fileID, '%s %s %8s %d %d %d %d %d %f  %f %d %d %d %d %d %d %d %d %d');
    fclose(fileID);
    
    fn = cell2char(C{1, 3});
    view = fn(:, 1:2);
    
    cancer = C{1, 4};
    calcs = C{1, 11};
    mass = C{1, 12};
    aln = C{1, 13};
    fasym = C{1, 14};
    dasym = C{1, 15};
    gasym = C{1, 16};
    asym = C{1, 17};
    arcd = C{1, 18};
    dd = C{1, 19};
    
    %Only graph Calcs Mass ARCD Asym (all asym grouped together)
    asym_all = asym + fasym + dasym + gasym;
    
    M = C(9:10);
    M = cell2mat(M);
    horz_pct = M(:, 1);
    vert_pct = M(:, 2);   
    
    cnt_cc_c = 1;
    cnt_mlo_c = 1;
    cnt_cc_b = 1;
    cnt_mlo_b = 1;
    horz_pct_cc_c = [];
    horz_pct_cc_b = [];
    horz_pct_mlo_c = [];
    horz_pct_mlo_b = [];
    for i = 1:size(view,1)
        if (strncmp(view(i,:), 'CC', 2) && (cancer(i) == 1))
            horz_pct_cc_c(cnt_cc_c) = horz_pct(i);
            vert_pct_cc_c(cnt_cc_c) = vert_pct(i);
            calcs_cc_c(cnt_cc_c) = calcs(i);
            mass_cc_c(cnt_cc_c) = mass(i);
            asym_all_cc_c(cnt_cc_c) = asym_all(i);
            arcd_cc_c(cnt_cc_c) = arcd(i);
            cnt_cc_c = cnt_cc_c + 1;
        elseif (strncmp(view(i,:), 'CC', 2) && (cancer(i) == 0))
            horz_pct_cc_b(cnt_cc_b) = horz_pct(i);
            vert_pct_cc_b(cnt_cc_b) = vert_pct(i);
            calcs_cc_b(cnt_cc_b) = calcs(i);
            mass_cc_b(cnt_cc_b) = mass(i);
            asym_all_cc_b(cnt_cc_b) = asym_all(i);
            arcd_cc_b(cnt_cc_b) = arcd(i);
            cnt_cc_b = cnt_cc_b + 1;
        elseif (strncmp(view(i,:), 'MLO', 2) && (cancer(i) == 1))
            horz_pct_mlo_c(cnt_mlo_c) = horz_pct(i);
            vert_pct_mlo_c(cnt_mlo_c) = vert_pct(i);
            calcs_mlo_c(cnt_mlo_c) = calcs(i);
            mass_mlo_c(cnt_mlo_c) = mass(i);
            asym_all_mlo_c(cnt_mlo_c) = asym_all(i);
            arcd_mlo_c(cnt_mlo_c) = arcd(i);
            cnt_mlo_c = cnt_mlo_c + 1;
        elseif (strncmp(view(i,:), 'MLO', 2) && (cancer(i) == 0))
            horz_pct_mlo_b(cnt_mlo_b) = horz_pct(i);
            vert_pct_mlo_b(cnt_mlo_b) = vert_pct(i);
            calcs_mlo_b(cnt_mlo_b) = calcs(i);
            mass_mlo_b(cnt_mlo_b) = mass(i);
            asym_all_mlo_b(cnt_mlo_b) = asym_all(i);
            arcd_mlo_b(cnt_mlo_b) = arcd(i);
            cnt_mlo_b = cnt_mlo_b + 1;
        end
    end
    
    xlim([minh maxh]); ylim([minv maxv]);
    if (cnt_cc_c > 1)
        figure(1); hold on;
        for j = 1:size(horz_pct_cc_c,2)
            color_str = 0;
            if (calcs_cc_c(j) == 1) color_str = '.r'; end
            if (mass_cc_c(j)== 1) color_str = '.g'; end
            if (asym_all_cc_c(j) == 1) color_str = '.b'; end
            if (arcd_cc_c(j)== 1) color_str = '.c'; end
            if ((calcs_cc_c(j) + mass_cc_c(j) + asym_all_cc_c(j) + arcd_cc_c(j)) > 1) color_str = '.m'; end
            %Only show mass  if ~strcmp(color_str, '.g') continue; end
            if (k == 2) color_str = '.k'; end
            if (k == 1) if (color_str) plot(horz_pct_cc_c(j), vert_pct_cc_c(j), color_str); end; end
        end              
        xlim([minh maxh]); ylim([minv maxv]);
        if (k == 1) title(strcat('CC Cancer-  ', int2str(cnt_cc_c-1), ' cases')); end
        xlabel('Calcs-Red Mass-Green Asym-Blue ARCD-Cyan Multi-Magenta');
        
        if (k == 2)
            p = polyfit(vert_pct_cc_c, horz_pct_cc_c, 2);
            yy = minv:0.01:maxv;
            xx = polyval(p,double(yy));
            plot(xx, yy, '.k');
        end
    end
    if (cnt_cc_b > 1)
        figure(2); hold on;
        for j = 1:size(horz_pct_cc_b,2)
            color_str = 0;
            if (calcs_cc_b(j) == 1) color_str = '.r'; end
            if (mass_cc_b(j)== 1) color_str = '.g'; end
            if (asym_all_cc_b(j) == 1) color_str = '.b'; end
            if (arcd_cc_b(j)== 1) color_str = '.c'; end
            if ((calcs_cc_b(j) + mass_cc_b(j) + asym_all_cc_b(j) + arcd_cc_b(j)) > 1) color_str = '.m'; end
            %Only show mass  if ~strcmp(color_str, '.g') continue; end
            if (k == 2) color_str = '.k'; end
            if (k == 1) if (color_str) plot(horz_pct_cc_b(j), vert_pct_cc_b(j), color_str); end; end
        end
        xlim([minh maxh]); ylim([minv maxv]);
        if (k == 1) title(strcat('CC Benign-  ', int2str(cnt_cc_b-1), ' cases')); end
        xlabel('Calcs-Red Mass-Green Asym-Blue ARCD-Cyan Multi-Magenta');
        
        if (k == 2)
            p = polyfit(vert_pct_cc_b, horz_pct_cc_b, 2);
            yy = minv:0.01:maxv;
            xx = polyval(p,double(yy));
            plot(xx, yy, '.k');
        end
    end
    if (cnt_mlo_c > 1)
        figure(3); hold on;
        for j = 1:size(horz_pct_mlo_c,2)
            color_str = 0;
            if (calcs_mlo_c(j) == 1) color_str = '.r'; end
            if (mass_mlo_c(j)== 1) color_str = '.g'; end
            if (asym_all_mlo_c(j) == 1) color_str = '.b'; end
            if (arcd_mlo_c(j)== 1) color_str = '.c'; end
            if ((calcs_mlo_c(j) + mass_mlo_c(j) + asym_all_mlo_c(j) + arcd_mlo_c(j)) > 1) color_str = '.m'; end
            %Only show mass  if ~strcmp(color_str, '.g') continue; end
            if (k == 2) color_str = '.k'; end
            if (k == 1) if (color_str) plot(horz_pct_mlo_c(j), vert_pct_mlo_c(j), color_str); end; end
        end
        xlim([minh maxh]); ylim([minv maxv]);
        if (k == 1) title(strcat('MLO Cancer-  ', int2str(cnt_mlo_c-1), ' cases')); end
        xlabel('Calcs-Red Mass-Green Asym-Blue ARCD-Cyan Multi-Magenta');
        
        if (k == 2)
            p = polyfit(vert_pct_mlo_c, horz_pct_mlo_c, 2);
            yy = minv:0.01:maxv;
            xx = polyval(p,double(yy));
            plot(xx, yy, '.k');
        end
    end
    if (cnt_mlo_b > 1)
        figure(4); hold on;
        for j = 1:size(horz_pct_mlo_b,2)
            color_str = 0;
            if (calcs_mlo_b(j) == 1) color_str = '.r'; end
            if (mass_mlo_b(j)== 1) color_str = '.g'; end
            if (asym_all_mlo_b(j) == 1) color_str = '.b'; end
            if (arcd_mlo_b(j)== 1) color_str = '.c'; end
            if ((calcs_mlo_b(j) + mass_mlo_b(j) + asym_all_mlo_b(j) + arcd_mlo_b(j)) > 1) color_str = '.m'; end
            %Only show mass  if ~strcmp(color_str, '.g') continue; end
            if (k == 2) color_str = '.k'; end
            if (k == 1) if (color_str) plot(horz_pct_mlo_b(j), vert_pct_mlo_b(j), color_str); end; end
        end
        xlim([minh maxh]); ylim([minv maxv]);
        if (k == 1) title(strcat('MLO Benign-  ', int2str(cnt_mlo_b-1), ' cases')); end
        xlabel('Calcs-Red Mass-Green Asym-Blue ARCD-Cyan Multi-Magenta');
        
        if (k == 2)
            p = polyfit(vert_pct_mlo_b, horz_pct_mlo_b, 2);
            yy = minv:0.01:maxv;
            xx = polyval(p,double(yy));
            plot(xx, yy, '.k');
        end
    end
    
end




   