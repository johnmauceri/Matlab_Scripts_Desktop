NIMG = 65;

    %{
    load test2.mat
    figure;
    y1 = hist(spic_var_angle(1:NIMG,1), 100);
    %figure;
    y2 = hist(norm_var_angle(1:NIMG,1), 100);
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
     %path = 'C:\Users\John Mauceri\Desktop\mstudy2_and_bstudy_256\spiculated\';
     path = 'C:\Users\John Mauceri\Desktop\mstudy2_and_bstudy_256\normal\';
     dir1 = dir(strcat(path, '*.png'));
     
     var_angle = zeros(size(dir1, 1),1);
     %for loop = 1: size(dir1)
     for loop = 1: NIMG
         loop
         dir1(loop).name
         im = imread(strcat(path,dir1(loop).name)); 
         im = im(:,:,1);
         figure(1); imagesc(im);  colormap('gray');
               
         FFT_EDGE_REMOVE_SIZE1 = int16(0.1*size(im,1));
         FFT_EDGE_REMOVE_SIZE2 = int16(0.1*size(im,2));
         
         cwtstruct = cwtft2(im,'wavelet',{'cauchy',{pi/12,1.0,4.0,4.0}},'scales',scales,'angles',angles);
                 
         cfs = zeros(size(im,1)-(2*FFT_EDGE_REMOVE_SIZE1), size(im,2)-(2*FFT_EDGE_REMOVE_SIZE2));
         for i = 1:size(angles,2)
             for j = 1:size(scales,2)
                 cfs(:,:)  = cfs(:,:)  + abs(cwtstruct.cfs(FFT_EDGE_REMOVE_SIZE1+1:size(im,1)-FFT_EDGE_REMOVE_SIZE1,FFT_EDGE_REMOVE_SIZE2+1:size(im,2)-FFT_EDGE_REMOVE_SIZE2,1,j,i));
             end
         end
         var_angle(loop,1) = var(cfs(:));
         figure(2); colormap('gray'); imagesc(cfs);
     end
     %spic_var_angle = var_angle;
     norm_var_angle = var_angle;
     save test2.mat spic_var_angle norm_var_angle

     
     
     
     