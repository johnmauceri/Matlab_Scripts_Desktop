%read full cancer iamges, check t0 versus t1 labele pre and post.
%for ben t0: is it postlabeled as t1
%for true cancer, is it postlabeled as t1
% dir1='C:\Users\vikas\Desktop\m-study_crops_plusboxedfullimage\full\cancer\';
% dirout='C:\Users\vikas\Desktop\m-study_crops_plusboxedfullimage\full\cancer\vein\';
clear;
dir1='C:\Users\vikas\Desktop\from_john\Bstudy_full_cancer_only_highQ_subset\';
dirout='C:\Users\vikas\Desktop\from_john\Bstudy_full_cancer_only_highQ_subset_vein\';

dir1='C:\Users\vikas\Desktop\from_john\Mstudy_benign_full\';
dirout='C:\Users\vikas\Desktop\from_john\Mstudy_benign_full_vein_T1_only\';

dir1='D:\from_john\Mstudy2_GT_part2\Mstudy2_GT\orig\';
dirout='D:\from_john\Mstudy2_GT_part2_vein\Can\';

dir1='G:\Arjan_study1_2_GT\orig\';%Bstudy_GT
dirout='G:\Arjan_study1_2_GT_vein\';

dir1='D:\mstudy2_cancer_masses_full_images\';
dirout='D:\mstudy2_cancer_masses_full_images_frangi\';

% dir1='C:\Users\vikas\Desktop\from_john\Mstudy_cancer_full\';
% dirout='D:\mstudy_cancer_calcs_full_images_frangi\';

d1=dir(dir1);
count_t0=0;
count_t0v1=0;
for i1=194 %3:size(d1,1)
    i1
    str1=d1(i1).name;
%     if(numel(strfind(str1,'Ben'))>0)
        if(1)
    I=imread(strcat(dir1,d1(i1).name));
    I=double(I);
    I=I(:,:,1);
    [Ivessel,whatScale,Direction]=FrangiFilter2D(I);
    b1=(Ivessel>0.15);%0.15, 0.2,0.1
    %mass is at lower scales but not dense tissue or vice versa?
    
    BW=b1;
    CC = bwconncomp(BW);
    % figure;imshow(BW);
    im=zeros(size(BW));
    for i=1:CC.NumObjects
        bd=CC.PixelIdxList{i};
        if(numel(bd)>1000)im(bd)=1;%1500
        end
    end
    
    
    %extract patch x,y and check for any veins found in region +-100
    %if not found, v=0, else v=1.
    q1=strfind(str1,'_');
    row1=str2num(str1(q1(8)+2:q1(9)-1));
    col1=str2num(str1(q1(7)+2:q1(8)-1));
    vflag='0';
%     %keep count of found t0s, and t0,v1 combos.
    %keep count of found t1s, and t1,v1 combos.
%     if(str1(q1(6)+2)=='0')
        if(1)
%         count_t0=count_t0+1
%         imp=im(row1-100:row1+100,col1-100:col1+100);
%         rr1=max(1,row1);%-100
%         cc1=max(1,col1);%-100
%         rr2=min(row1+100,size(I,1));
%         cc2=min(col1+100,size(I,2));
%         
%         imp=im(rr1:rr2,cc1:cc2);
%         if(nnz(imp)>0)
% %             count_t0v1=count_t0v1+1
%             vflag='1';
%         else
%             vflag='0';
%         end
    end
%     if(str1(q1(6)+2)=='0')
    if(1)
    imwrite(im,strcat(dirout,str1,'_v',(vflag),'_vein.jpg'));
    end
    end
end

% dir1='D:\from_john\Mstudy2_GT_vein\ben\';
% d1=dir(dir1);
% for i=3:numel(d1)
% d=d1(i).name;
% s1=strfind(d,'_vein.jpg');
% v(i)=str2num(d(s1-1));
% s2=strfind(d,'Q');
% s3=strfind(d,'_T');
% q(i)=str2num(d((s2+1):(s3-1)));
% end
% nnz(v>0&q>20)/nnz(q>20)