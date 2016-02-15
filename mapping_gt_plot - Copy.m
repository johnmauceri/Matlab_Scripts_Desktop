clear all
DestGT = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location3\mapping_noheaders.txt';
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
minh = min(horz_pct);
maxh = max(horz_pct);
minv = min(vert_pct);
maxv = max(vert_pct);


cnt_cc_c = 1;
cnt_mlo_c = 1;
cnt_cc_b = 1;
cnt_mlo_b = 1;
for i = 1:size(view,1)
    if (strncmp(view(i,:), 'CC', 2) && (cancer(i) == 1))
        horz_pct_cc_c(cnt_cc_c) = horz_pct(i);
        vert_pct_cc_c(cnt_cc_c) = vert_pct(i);
        cnt_cc_c = cnt_cc_c + 1;
    elseif (strncmp(view(i,:), 'CC', 2) && (cancer(i) == 0))
        horz_pct_cc_b(cnt_cc_b) = horz_pct(i);
        vert_pct_cc_b(cnt_cc_b) = vert_pct(i);
        cnt_cc_b = cnt_cc_b + 1;
    elseif (strncmp(view(i,:), 'MLO', 2) && (cancer(i) == 1))
        horz_pct_mlo_c(cnt_mlo_c) = horz_pct(i);
        vert_pct_mlo_c(cnt_mlo_c) = vert_pct(i);
        cnt_mlo_c = cnt_mlo_c + 1;
    elseif (strncmp(view(i,:), 'MLO', 2) && (cancer(i) == 0))
        horz_pct_mlo_b(cnt_mlo_b) = horz_pct(i);
        vert_pct_mlo_b(cnt_mlo_b) = vert_pct(i);
        cnt_mlo_b = cnt_mlo_b + 1;
    end
end

xlim([minh maxh]); ylim([minv maxv]);
if (cnt_cc_c > 1)
    figure(1); plot(horz_pct_cc_c, vert_pct_cc_c, '.');
    xlim([minh maxh]); ylim([minv maxv]);
    title(strcat('CC Cancer-  ', int2str(cnt_cc_c-1), ' cases'));
end
if (cnt_cc_b > 1)
    figure(2); plot(horz_pct_cc_b, vert_pct_cc_b, '.');
    xlim([minh maxh]); ylim([minv maxv]);
    title(strcat('CC Benign-  ', int2str(cnt_cc_b-1), ' cases'));
end
if (cnt_mlo_c > 1)
    figure(3); plot(horz_pct_mlo_c, vert_pct_mlo_c, '.');
    xlim([minh maxh]); ylim([minv maxv]);
    title(strcat('MLO Cancer-  ', int2str(cnt_mlo_c-1), ' cases'));
end
if (cnt_mlo_b > 1)
    figure(4); plot(horz_pct_mlo_b, vert_pct_mlo_b, '.');
    xlim([minh maxh]); ylim([minv maxv]);
    title(strcat('MLO Benign-  ', int2str(cnt_mlo_b-1), ' cases'));
end






   