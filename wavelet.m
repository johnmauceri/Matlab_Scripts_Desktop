     %close all;
     
     I = zeros(100, 100);
     im = zeros(200, 200);
     I(:,50) = 1;
     I = I + imrotate(I, 45/2, 'crop') + imrotate(I, 45, 'crop') + imrotate(I, 45+45/2, 'crop') + imrotate(I, 90, 'crop') + imrotate(I, 90+45/2, 'crop') + imrotate(I, 90+45, 'crop') + imrotate(I, 90+45+45/2, 'crop');
     I = I > 0;
     %imwrite(I, 'C:\Users\John Mauceri\DICOM_TEST\MathlabScripts\lines_star_wavelet_test.jpg');
     %im(1:100,1:100) = I; im(101:200,1:100) = I; im(1:100,101:200) = I; im(101:200,101:200) = I;
     im = I;
     
     %im = imread('C:\Users\John Mauceri\Desktop\Jenna-06-03-2015\P4_493061_t1_20150602_112614_R_CC_________CROP.jpg');
     %im = imread('C:\Users\John Mauceri\Desktop\P8_491216_t1_20150602_074316_L_MLO_________.jpg');
     %im = imread('C:\Users\John Mauceri\Desktop\M00004_42612752_t3_20150302_082756_L_CC_Cancer_L_Cancer_irregular-mass-with-microlobulated-margins_Invasive-ductal-carcinoma_ct_0_dns_2.jpg');
     %im = imread('C:\Users\John Mauceri\Desktop\mstudy2_and_bstudy_gt_crops\M00138_41929101_t3_20131002_180142_L_MLO_Cancer_L_Cancer_oval-mass-with-indistinct-margins_Invasive-ductal-carcinoma_ct_0_dns_1.dcm_2411_2946_gt.png');
     %im = imread('star.jpg');
     %im = imread('hexagon.jpg'); im = 255-im; im = im > 127     
     im = im(:,:,1);
     %figure(1); imagesc(im);  colormap('gray');
     
     %{
     Y = zeros(64, 64);
     Y(32,32) = 1;
     cwtstruct = cwtft2(Y,'wavelet',{'cauchy',{pi/12,1.0,4.0,4.0}},'scales',1,'angles',[0 pi/2]);
     figure; surf(abs(cwtstruct.cfs(:,:,1,1,1))); shading interp;
     %}
     
     
     %{
     figure(4); [C, h] = contourf(flipud(im),1); set(h,'LineColor','none'); colormap('gray');
     [x,y,z] = C2xyz(C);
     S = contourcs(flipud(double(im)), 1);
     %}
     
     %{
     figure(5); [C, h] = contourf(flipud(im),2); set(h,'LineColor','none'); colormap('gray'); set(gca, 'position',[0 0 1 1]);
     
     F = getframe(5);
     [X, Map] = frame2im(F);
     figure(2); imagesc(X);  colormap('gray');
     X = X(:,:,1);
     X1 = ((X > 200));
     X2 = ((X > 100));
     X = X2 - X1;
     figure; imagesc(X);  colormap('gray');
     
     [x,y,z] = C2xyz(C);
     S = contourcs(flipud(double(im)), 2);
     %}
     
     
     %{
     im2 = im>200;
     im3 = im>120;
     im4 = im3-im2;
     figure(6); imagesc(im4);  colormap('gray');
     %}
    
     
     scales = 1:10;
     angles = 0:pi/8:pi-pi/8;
     angz = {'0', 'pi/8', 'pi/4', '3pi/8', 'pi/2', '5pi/8', '3pi/4', ...
    '7pi/8','pi', '9pi/8', '5pi/4', '11pi/8', '3pi/2', ...
    '13pi/8' '7pi/4', '15pi/8'};
     path = 'C:\Users\John Mauceri\Desktop\mstudy2_and_bstudy_gt_crops\';
     %path = 'C:\Users\John Mauceri\Desktop\mstudy2_and_bstudy_normal_tissue\';
     dir1 = dir(strcat(path, '*.png'));
     %figure(2); cwtstruct = cwtft2(im,'wavelet','cauchy','scales',scales,'angles',angles,'plot');
     
     var_angle = zeros(size(dir1, 1), size(angles,2));
     for loop = 1: size(dir1)
         im = imread(strcat(path,dir1(loop).name)); 
         if loop==2 im = imread('C:\Users\John Mauceri\Desktop\M00004_42612752_t3_20150302_082756_L_CC_Cancer_L_Cancer_irregular-mass-with-microlobulated-margins_Invasive-ductal-carcinoma_ct_0_dns_2.jpg'); end
         if loop==1 im = imread('C:\Users\John Mauceri\Desktop\mstudy2_and_bstudy_gt_crops\M00138_41929101_t3_20131002_180142_L_MLO_Cancer_L_Cancer_oval-mass-with-indistinct-margins_Invasive-ductal-carcinoma_ct_0_dns_1.dcm_2411_2946_gt.png'); end
         figure(1); imagesc(im);  colormap('gray');
         
         cwtstruct = cwtft2(im,'wavelet',{'cauchy',{pi/12,1.0,4.0,4.0}},'scales',scales,'angles',angles);        
         
         
         for i = 1:size(angles,2)
             cfs = zeros(size(im,1), size(im,2));
             for j = 1:size(scales,2)
                 cfs(:,:) = cfs(:,:) + abs(cwtstruct.cfs(:,:,1,j,i));
                 %figure; colormap('gray'); imagesc(cfs); title(['Cauchy angle ' angz(i) 'Scale' j]);
                 %figure; surf(abs(cwtstruct.cfs(:,:,1,j,i))); shading interp;
             end
             %if (var(cfs(:))>6) figure(3); colormap('gray'); imagesc(cfs); title(['Cauchy angle ' angz(i)]); end
             figure; colormap('gray'); imagesc(cfs); title(['Cauchy angle ' angz(i)]);
             var_angle(loop,i) = var(cfs(:));
         end
         %figure; colormap('gray'); imagesc(cfs); title(['Cauchy angle ' angz(i)]);
         loop
         dir1(loop).name
     end
     [rowInd,colInd,zInd]=ind2sub(size(var_angle),find(var_angle));
     figure; scatter3(colInd, rowInd, zInd, '.');
     
     
     
     