
    %{
    figure;
    y1 = hist(gt_var_angle(1:79,1), 100);
    %figure;
    y2 = hist(norm_var_angle(1:79,1), 100);
    %bar([y1.' y2.'],'stacked')
    bar(y2.');
    hold on;
    bar(y1.','y');
    %}

     scales = 1:10;
     angles = 0:pi/8:pi-pi/8;
     angz = {'0', 'pi/8', 'pi/4', '3pi/8', 'pi/2', '5pi/8', '3pi/4', ...
    '7pi/8','pi', '9pi/8', '5pi/4', '11pi/8', '3pi/2', ...
    '13pi/8' '7pi/4', '15pi/8'};
     path = 'C:\Users\John Mauceri\Desktop\mstudy2_and_bstudy_gt_crops\';
     %path = 'C:\Users\John Mauceri\Desktop\mstudy2_and_bstudy_normal_tissue\';
     dir1 = dir(strcat(path, '*.png'));
     dir1 = dir(strcat(path, '*spiculat*'));
     
     var_angle = zeros(size(dir1, 1),8);
     for loop = 1: size(dir1)
         loop
         dir1(loop).name
         im = imread(strcat(path,dir1(loop).name)); 
         %if loop==1 im = imread('C:\Users\John Mauceri\Desktop\M00004_42612752_t3_20150302_082756_L_CC_Cancer_L_Cancer_irregular-mass-with-microlobulated-margins_Invasive-ductal-carcinoma_ct_0_dns_2.jpg'); end
         %if loop==2 im = imread('C:\Users\John Mauceri\Desktop\mstudy2_and_bstudy_gt_crops\M00138_41929101_t3_20131002_180142_L_MLO_Cancer_L_Cancer_oval-mass-with-indistinct-margins_Invasive-ductal-carcinoma_ct_0_dns_1.dcm_2411_2946_gt.png'); end
         im = im(:,:,1);
         figure(1); imagesc(im);  colormap('gray');
          
         figure(4); [C, h] = contourf(flipud(im),2); set(h,'LineColor','none'); colormap('gray'); set(gca, 'position',[0 0 1 1]); 
         F = getframe(4);
         [X, Map] = frame2im(F);
         X = X(:,:,1); 
         X = ((X > 100) & (X < 200));
         X = imresize(X, [size(im,1) size(im,2)]);
         figure(5); imagesc(X);  colormap('gray'); set(gca, 'position',[0 0 1 1]); 
               
         FFT_EDGE_REMOVE_SIZE1 = int16(0.1*size(im,1));
         FFT_EDGE_REMOVE_SIZE2 = int16(0.1*size(im,2));
         
         cwtstruct = cwtft2(im,'wavelet',{'cauchy',{pi/12,1.0,4.0,4.0}},'scales',scales,'angles',angles);
                  
         X = X(FFT_EDGE_REMOVE_SIZE1+1:size(im,1)-FFT_EDGE_REMOVE_SIZE1,FFT_EDGE_REMOVE_SIZE2+1:size(im,2)-FFT_EDGE_REMOVE_SIZE2);
         cfs = zeros(size(im,1)-(2*FFT_EDGE_REMOVE_SIZE1), size(im,2)-(2*FFT_EDGE_REMOVE_SIZE2));
         cfs2 = zeros(size(im,1)-(2*FFT_EDGE_REMOVE_SIZE1), size(im,2)-(2*FFT_EDGE_REMOVE_SIZE2));
         for i = 1:size(angles,2)
             %cfs = zeros(size(im,1)-(2*FFT_EDGE_REMOVE_SIZE1), size(im,2)-(2*FFT_EDGE_REMOVE_SIZE2));
             for j = 1:size(scales,2)
                 cfs(:,:)  = cfs(:,:)  + abs(X .* cwtstruct.cfs(FFT_EDGE_REMOVE_SIZE1+1:size(im,1)-FFT_EDGE_REMOVE_SIZE1,FFT_EDGE_REMOVE_SIZE2+1:size(im,2)-FFT_EDGE_REMOVE_SIZE2,1,j,i));
                 cfs2(:,:) = cfs2(:,:) + abs(cwtstruct.cfs(FFT_EDGE_REMOVE_SIZE1+1:size(im,1)-FFT_EDGE_REMOVE_SIZE1,FFT_EDGE_REMOVE_SIZE2+1:size(im,2)-FFT_EDGE_REMOVE_SIZE2,1,j,i));
             end
             %if (var(cfs(:)) > 6) 
                 %figure(2); colormap('gray'); imagesc(cfs); title(['Cauchy angle ' angz(i)]);
             %end
         end
         cfs=255*(cfs-min(cfs(:)))/(max(cfs(:))-min(cfs(:)));
         cfs2=255*(cfs2-min(cfs2(:)))/(max(cfs2(:))-min(cfs2(:)));
         var_angle(loop,1) = int16(var(cfs(cfs>0)));
         var_angle(loop,2) = int16(var(cfs2(:)));
         var_angle(loop,3) = int16(mean(cfs(cfs>0)));
         var_angle(loop,4) = int16(mean2(cfs2));
         var_angle(loop,5) = int16(min(cfs(cfs>0)));
         var_angle(loop,6) = int16(min(cfs2(:)));
         var_angle(loop,7) = int16(max(cfs(cfs>0)));
         var_angle(loop,8) = int16(max(cfs2(:)));
         figure(2); colormap('gray'); imagesc(cfs);
         figure(3); colormap('gray'); imagesc(cfs2);
     end

     
     
     
     