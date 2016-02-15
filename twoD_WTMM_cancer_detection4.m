     im = imread('C:\Users\John Mauceri\Desktop\Can1_1_RCC_M00001_t3_Q0_T0_X1942_Y1341_269X269_07X07.jpg');
     %im = imread('C:\Users\John Mauceri\Desktop\Can1_1_RCC_M01_t3_Q605_T0_X2032_Y1428_100X100_07X07.jpg');
     %figure; imagesc(im);  colormap('gray');  view(-90,90);

     conn = 1; %3 by 3
     %conn = 2; %5 by 5
     %conn = 3; %7 by 7
     
     
     scales = 1:0.25:25;
     cwtstruct = cwtft2(im,'wavelet','gaus2','scales',scales,'angles',0);
                
     cfs = abs(cwtstruct.cfs(:,:,1,:,1));
     
     lmaxima3 = zeros(size(im,1), size(im,2), size(scales,2));
     for i = 1:size(scales,2)
         %figure; colormap('gray'); imagesc(abs(cwtstruct.cfs(:,:,1,i,1))); title(['Gaus2 scale ' int2str(i)]); view(-90,90);
     
         [lmaxima,indices] = localmax(cwtstruct.cfs(:,:,1,i,1),[],false);
         [lmaxima2,indices2] = localmax(transpose(cwtstruct.cfs(:,:,1,i,1)),[],false);
  
         %figure; colormap('gray'); imagesc(lmaxima); title(['Maxima scale ' int2str(i)]); view(-90,90);
         
         %figure; colormap('gray'); imagesc(transpose(lmaxima2)); title(['Maxima2 scale ' int2str(i)]); view(-90,90);
         
         lmaxima3(:,:,i) = lmaxima + transpose(lmaxima2);
         %figure; colormap('gray'); imagesc(lmaxima3(:,:,i)); title(['Maxima3 scale ' int2str(i)]); view(-90,90);
     end
    
     i = 1;
     figure; colormap('gray'); imagesc(lmaxima3(:,:,i)); title(['Maxima3 scale ' int2str(i)]); view(-90,90);
     
     %Find boundary of MC
     i = 1;
     ms = mean2(abs(cwtstruct.cfs(:,:,1,i,1))) + 3 * std2(abs(cwtstruct.cfs(:,:,1,i,1)));   
     boundary(:,:,i) = abs(cwtstruct.cfs(:,:,1,i,1)) > ms;
     boundary(1:5,:) = 0; boundary(size(im,1)-4:size(im,1),:) = 0;
     boundary(:,1:5) = 0; boundary(:,size(im,2)-4:size(im,2),:) = 0;
     figure; colormap('gray'); imagesc(boundary(:,:,i)); view(-90,90)
     
     %Get Curves on MC's or off
     lmaxima3(:,:,i) = lmaxima3(:,:,i) .* boundary(:,:,i);
     %lmaxima3(:,:,i) = lmaxima3(:,:,i) .* ~boundary(:,:,i);
     figure; colormap('gray'); imagesc(lmaxima3(:,:,i)); title(['Maxima3 scale ' int2str(i)]); view(-90,90);
     
     
     %Chain Maxium on Scale
     figure; hold on;
     for i = 2:size(im,1)-1
         for j = 2:size(im,2)-1
             if (lmaxima3(i,j,1) == 0) continue; end
             BW = zeros(size(im,1), size(im,2), size(scales,2));
             cnt = 1;
             BW(i,j,1) = 1;
             r = i;
             c = j;
             for k = 2: size(scales,2)
                 mx = 0;
                 idx_m = 0;
                 idx_n = 0;
                 for m = r-conn:r+conn
                     if ((m < 1) || (m > size(im,1))) continue; end
                     for n = c-conn:c+conn
                         if ((n < 1) || (n > size(im,2))) continue; end
                         if (lmaxima3(m,n,k) > mx)
                             mx = lmaxima3(m,n,k); 
                             r = m;
                             c = n;
                         end
                     end
                 end
                 if (mx == 0) 
                     break;
                 end    
                 BW(r,c,k) = 1;
                 cnt = cnt + 1;
             end
             if (cnt > (size(scales,2)/4))
                 [rowInd,colInd,zInd]=ind2sub(size(BW),find(BW));
                 plot3(rowInd,colInd,zInd); xlim([0 size(im,1)]); ylim([0 size(im,2)]); zlim([0 size(scales,2)]); view(-39, 30);
                 view(0,90);
             end
         end
     end
     set(gca,'Zscale','log');
     close all