     close all;
     im = imread('C:\Users\John Mauceri\Desktop\Can1_1_RCC_M00001_t3_Q0_T0_X1942_Y1341_269X269_07X07.jpg');
     %im = imread('C:\Users\John Mauceri\Desktop\Can1_1_RCC_M01_t3_Q605_T0_X2032_Y1428_100X100_07X07.jpg');
     figure; imagesc(im);  colormap('gray');

     conn = 1; %3 by 3
     %conn = 2; %5 by 5
     %conn = 3; %7 by 7
     
     scales = 1:.25:15;
     cwtstruct = cwtft2(im,'wavelet','gaus2','scales',scales,'angles',0);
     cfs = abs(cwtstruct.cfs(:,:,1,:,1));
     cfs2 = zeros(size(im,1), size(im,2), size(scales,2));
     cfs2(:,:,:) = abs(cwtstruct.cfs(:,:,1,:,1));
     figure; colormap('gray'); imagesc(cfs2(:,:,1)); title(['Gaus2 scale ' int2str(1)]);
     im_max = imregionalmax(cfs,26);
     figure; colormap('gray'); imagesc(im_max(:,:,1)); title(['Maxima scale ' int2str(1)]);
     
     [rowInd,colInd,zInd]=ind2sub(size(im_max),find(im_max));
     %figure; scatter3(colInd, rowInd, zInd, '.');   
     
     wtmm = zeros(size(im,1), size(im,2), size(scales,2));
     wtmm = im_max(:,:,:);
     
     %Chain Maxium on Scale using Matlab
     CC = bwconncomp(wtmm, 26);
     
     figure(1); hold on;
     figure(2); hold on;
     figure(3); hold on;
     figure(4); hold on;
     figure(5); hold on;
     numPixels = cellfun(@numel,CC.PixelIdxList);
     [biggest,idx] = max(numPixels);
     for i = 1: CC.NumObjects
         if (numPixels(i) < 2) continue; end
         im_max3 = logical(zeros(size(im,1), size(im,2), size(scales,2)));
         im_max3(CC.PixelIdxList{i}) = 1;
         
         [x,y,z] = ind2sub(size(im_max3), CC.PixelIdxList{i});    
  %check if the orientation correct   
         figure(5); scatter(y, x, '.'); xlim([0 size(im,1)]); ylim([0 size(im,2)]);
         
         for a = 1: size(x,1)
             t(a) = cfs2(x(a),y(a),z(a));
         end
         p = polyfit(log(1:size(x,1)), log(t(1:size(x,1))), 1);
         holder_exp = p(1); %Holder exponient is the slope of the line.
         if (holder_exp < 0)
             figure(4); plot(log(1:size(x,1)), log(t(1:size(x,1))));
             %figure(4); plot(log(1:size(x,1)), polyval(p, log(1:size(x,1))));
         else
             continue;
         end
         

         
         
         Z =  zeros(7, size(x,1));
         for a = 1: size(x,1)
             for q = -3:3
                 Z(q+4,a) = Z(q+4,a) + cfs2(x(a),y(a),z(a))^q;
             end
         end
         for q = -3:3
             figure(1); plot(log2(1:size(x,1)), log2(Z(q+4,1:size(x,1))));
             p = polyfit(log2(1:size(x,1)), log2(Z(q+4,1:size(x,1))), 1);
             %figure(1); plot(log2(1:size(x,1)), polyval(p, log2(1:size(x,1))));
             tau(q+4) = p(1);
         end
         figure(2); plot(-3:3, tau);
         for q = -1:3
             %Check if all the slopes are the same
             if (abs((tau(q+4) - tau(q+3)) - (tau(q+3) - tau(q+2))) > 0.0001)
                 (tau(q+4) - tau(q+3))/(1)
                 (tau(q+3) - tau(q+2))/(1)
             end
         end
         
         %{
         cnt = 1;
         for h = 0.2:0.01:0.6
             D(cnt) = 0;
             for q = -3:3
                 D(cnt) = D(cnt) + (q * h) - tau(q+4);
             end
             cnt = cnt + 1;
         end
         plot(0.2:0.01:0.6, D);
         %}

         
         [rowInd,colInd,zInd]=ind2sub(size(im_max3),find(im_max3));
         figure(3); plot3(rowInd,colInd,zInd); xlim([0 size(im,1)]); ylim([0 size(im,2)]); zlim([0 size(scales,2)]); view(-39, 30);
         %view(0,90);
     end
     
     %Looks like logical values alone are the same and this is not needed
     im_max2 = wtmm .* cfs2;
        
     %Chain Maxium on Scale my way
     figure(4); hold on;
     figure(5); hold on;
     figure(6); hold on;
     for i = 2:size(im,1)-1
         for j = 2:size(im,2)-1
             if (im_max2(i,j,1) == 0) continue; end
             BW = zeros(size(im,1), size(im,2), size(scales,2));
             cnt = 1;
             BW(i,j,1) = 1; 
             r = i;
             c = j;
             Z =  zeros(7, size(scales,2));
             for q = -3:3
                 Z(q+4,1) = Z(q+4,1) + im_max2(r,c,1)^q;
             end
             for k = 2: size(scales,2)
                 mx = 0;
                 idx_m = 0;
                 idx_n = 0;
                 for m = r-conn:r+conn
                     if ((m < 1) || (m > size(im,1))) continue; end
                     for n = c-conn:c+conn
                         if ((n < 1) || (n > size(im,2))) continue; end
                         if (im_max2(m,n,k) > mx)
                             mx = im_max2(m,n,k); 
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
                 for q = -3:3
                     Z(q+4,k) = Z(q+4,k) + im_max2(r,c,k)^q;
                 end          
             end     

             if (cnt < 2) continue; end
             for q = -3:3
                 figure(4); plot(log2(1:cnt), log2(Z(q+4,1:cnt)));
                 p = polyfit(log2(1:cnt), log2(Z(q+4,1:cnt)), 1);
                 %plot(log2(1:cnt), polyval(p, log2(1:cnt)));
                 tau(q+4) = p(1);
             end
             figure(5); plot(-3:3, tau);
             for q = -1:3
                 %Check if all the slopes are the same
                 if (abs((tau(q+4) - tau(q+3)) - (tau(q+3) - tau(q+2))) > 0.0001)
                     (tau(q+4) - tau(q+3))/(1)
                     (tau(q+3) - tau(q+2))/(1)
                 end
             end
                 
             %{
             cnt = 1;
             for h = 0.2:0.01:0.6
                 D(cnt) = 0;
                 for q = -3:3
                     D(cnt) = D(cnt) + (q * h) - tau(q+4);
                 end
                 cnt = cnt + 1;
             end
             plot(0.2:0.01:0.6, D);
             %}     
             
             [rowInd,colInd,zInd]=ind2sub(size(BW),find(BW));
             figure(6); plot3(rowInd,colInd,zInd); xlim([0 size(im,1)]); ylim([0 size(im,2)]); zlim([0 size(scales,2)]); view(-39, 30);
             %view(0,90);
         end
     end
     %set(gca,'Zscale','log');
         

     %close all;
     
 %{    
         Z =  zeros(7, size(scales,2));
         im_max4 = im_max3 .* cfs2;
         for a = 1: size(scales,2)
             for q = -3:3:3
                 if (size(find(im_max4(:,:,a) ~= 0),1)) 
                     Z(q+4,a) = Z(q+4,a) + im_max4(10000 * (a-1) + max(find(im_max4(:,:,a) ~= 0)))^q;
                 end
             end
         end
         figure; hold on;
         for q = -3:3:3
             %plot(log2(1:size(scales,2)), log2(Z(q+4,1:size(scales,2))));
             plot(log2(scales), log2(Z(q+4,1:size(scales,2))));
         end
     %}