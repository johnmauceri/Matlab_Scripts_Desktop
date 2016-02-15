Source = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\Mstudy\Case Log.txt'; 

SourceData = 'C:\Users\John Mauceri\Desktop\Mstudy\';

SAMPLE_SQUARE = 100;
PERCENT_BLACK = 0.5;
REDUCE_RECT_PCT = 0.25;


FID = fopen(Source);
fgetl(FID);
C = textscan(FID, '%s %s %s %f %f %f');
fclose(FID);

tmp = strrep(C{1, 1}, 'UCSD', '');
filename = strcat(SourceData, tmp, '\', tmp, '_', C{1, 2}, '*.dcm');
fn = strcat(SourceData, tmp);
M = C(4:end);
M = cell2mat(M);
[m, n] = size(M);
side = C{3};
location = C{4};
cmfn = C{5};
    
for i = 1: m
    files = dir(filename{i});
    tmp = strfind(side(i), 'eft');
    rl = isempty(tmp{1});
    for file = files'
        if ((isempty(strfind(file.name, '_L_')) && rl) || (~isempty(strfind(file.name, '_L_')) && ~rl))
            I = dicomread(fullfile(fn{i}, file.name));
            INFO = dicominfo(fullfile(fn{i}, file.name));
            ps = INFO.PixelSpacing;
            height = INFO.Height;
            width = INFO.Width;
             
            Iboundary=(imdilate(double(I==0),ones(15)));
            %figure;
            %imagesc(Iboundary);
            %colormap gray;
            Iboundary(end-500:end,:)=1;
            %figure;
            %imagesc(Iboundary);
            %colormap gray;
                
            BW = edge(Iboundary);
                
            [Ibx,Iby]=find(BW==1);
            %Ibx_flip = double(height) - Ibx;
            %figure;
            %scatter(Ibx, Iby, 1);
            %scatter(Iby, Ibx_flip, 1);
            p = polyfit(Ibx, Iby, 2);
            
            x = min(Ibx):1:max(Ibx);
            y = polyval(p,double(x));

            y_nip = min(y);
            x_nip = x(find(y==y_nip));
            
            tmpx = [(x(1):((x_nip - x(1) + 1) / 3.0): x_nip) (x_nip:((x(end) - x_nip + 1) / 3.0): x(end))];
            tmpx(7) = x(end);
            tmpy = [y_nip y_nip y_nip y_nip y_nip y_nip y_nip];
            tmpy2 = [max(y) max(y) max(y) max(y) max(y) max(y) max(y)];
            
            figure;
            plot(Ibx, Iby, '.', x, y, x_nip, y_nip, 'o', tmpx, tmpy, '.');
            
            if (~isempty(strfind(file.name, 'MLO')))
                %MLO case
                if (rl)
                    %right
                else
                    %left
                end
            end
            if (~isempty(strfind(file.name, 'CC')))
                %CC case
                if (rl)
                    %right
                    if (location(i) == 9)
                        line([tmpx(1) tmpx(1)],[tmpy(1) tmpy2(1)]);
                    end
                    if ((location(i) == 10) || (location(i) == 8))
                        line([tmpx(2) tmpx(2)],[tmpy(2) tmpy2(2)]);
                    end
                    if ((location(i) == 11) || (location(i) == 7))
                        line([tmpx(3) tmpx(3)],[tmpy(3) tmpy2(3)]);
                    end
                    if ((location(i) == 12) || (location(i) == 6))
                        line([tmpx(4) tmpx(4)],[tmpy(4) tmpy2(4)]);
                    end
                    if ((location(i) == 1) || (location(i) == 5))
                        line([tmpx(5) tmpx(5)],[tmpy(5) tmpy2(5)]);
                    end
                    if ((location(i) == 2) || (location(i) == 4))
                        line([tmpx(6) tmpx(6)],[tmpy(6) tmpy2(6)]);
                    end
                    if (location(i) == 3)
                        line([tmpx(7) tmpx(7)],[tmpy(7) tmpy2(7)]);
                    end
                else
                    %left
                    if (location(i) == 9)
                        line([tmpx(7) tmpx(7)],[tmpy(7) tmpy2(7)]);
                    end
                    if ((location(i) == 10) || (location(i) == 8))
                        line([tmpx(6) tmpx(6)],[tmpy(6) tmpy2(6)]);
                    end
                    if ((location(i) == 11) || (location(i) == 7))
                        line([tmpx(5) tmpx(5)],[tmpy(5) tmpy2(5)]);
                    end
                    if ((location(i) == 12) || (location(i) == 6))
                        line([tmpx(4) tmpx(4)],[tmpy(4) tmpy2(4)]);
                    end
                    if ((location(i) == 1) || (location(i) == 5))
                        line([tmpx(3) tmpx(3)],[tmpy(3) tmpy2(3)]);
                    end
                    if ((location(i) == 2) || (location(i) == 4))
                        line([tmpx(2) tmpx(2)],[tmpy(2) tmpy2(2)]);
                    end
                    if (location(i) == 3)
                        line([tmpx(1) tmpx(1)],[tmpy(1) tmpy2(1)]);
                    end
                end
            end
            
        end
    end
end 

    cnt = 1;
    for loop = filename'
        file = num2str(cell2mat(loop));
        if ~exist(file)
            display('Error file not found.', file);
            cnt = cnt + 1;
            continue
        end

        I = dicomread(file);
        IC = I;
        %imagesc(I);
        %colormap gray;
        INFO = dicominfo(file);
        
        try
            ps1 = num2str(INFO.PixelSpacing(1));         
        catch 
            ps1 = '0.0';
            ps2 = '0.0';
            display('Error: No Pixel Spacing in file:', file);
        end
        if (~strcmp(ps1,'0.0'))  ps2 = num2str(INFO.PixelSpacing(2)); end;
        
        height = INFO.Height;
        width = INFO.Width;
        Q = M(cnt, 1);
        type = M(cnt, 2);
        Y = height - M(cnt, 4);
        if (file(strfind(file, '_L_')+1) == 'L')
            X = width - M(cnt, 3);
            Xmax = width - M(cnt, 5);
            Xmin = width - M(cnt, 6);
        else
            X = M(cnt, 3);
            Xmin = M(cnt, 5);
            Xmax = M(cnt, 6);
        end
        
        Xmin = M(cnt, 5);
        Xmax = M(cnt, 6);
        Ymax = height - M(cnt, 7);
        Ymin = height - M(cnt, 8);
        rect = zeros(1, 4);
    
        if ((Xmax - Xmin) < SAMPLE_SQUARE)
            rect(1) = X - (SAMPLE_SQUARE / 2);
            rect(3) = SAMPLE_SQUARE - 1;
        elseif ((REDUCE_RECT_PCT * (Xmax - Xmin)) < SAMPLE_SQUARE)
            rect(1) = X - (SAMPLE_SQUARE / 2);
            rect(3) = SAMPLE_SQUARE - 1;  
        else
            rect(1) = X - (REDUCE_RECT_PCT * ((Xmax - Xmin) / 2));
            rect(3) = REDUCE_RECT_PCT * (Xmax - Xmin);
        end
        
        if ((Ymax - Ymin) < SAMPLE_SQUARE)
            rect(2) = Y - (SAMPLE_SQUARE / 2);
            rect(4) = SAMPLE_SQUARE - 1;
        elseif ((REDUCE_RECT_PCT * (Ymax - Ymin)) < SAMPLE_SQUARE)
            rect(2) = Y - (SAMPLE_SQUARE / 2);
            rect(4) = SAMPLE_SQUARE - 1;   
        else
            rect(2) = Y - (REDUCE_RECT_PCT * ((Ymax - Ymin) / 2));
            rect(4) = REDUCE_RECT_PCT * (Ymax - Ymin);
        end
        if (rect(1) < 1) rect(1) = 1; end;
        if (rect(2) < 1) rect(2) = 1; end;
        
        rect = int64(rect);
        I = imcrop(I, rect);
        %figure
        %imagesc(I);
        %colormap gray;
        A = im2col(I, [SAMPLE_SQUARE SAMPLE_SQUARE], 'distinct');
        sz= size(A);
        tmp = strrep(directory(cnt), '/', '_');
        desc = strrep(INFO.SeriesDescription, ' ', '');
        if (desc(1) == 'M')           
            desc = strcat(strrep(file(strfind(file, '_R_')+1:strfind(file, '_R_')+5), '_', ''),strrep(file(strfind(file, '_L_')+1:strfind(file, '_L_')+5), '_', ''));
        end
        xinc = 0;
        yinc = 0;
        for n = 1: sz(2)
            B = reshape(A(:,n), SAMPLE_SQUARE, SAMPLE_SQUARE);
            %figure
            %imagesc(B);
            %colormap gray;

            fn = fullfile(dirDest, strcat('Can',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp{1}, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)+xinc), '_', 'Y', num2str(rect(2)+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', ps1, 'X', ps2, '.jpg'));
            fn_full = fullfile(dirDest, strcat('Can',  int2str(cnt), '_', int2str(n), '_', desc, '_', tmp{1}, '_Q', num2str(Q), '_T', num2str(type), '_X', num2str(rect(1)+xinc), '_', 'Y', num2str(rect(2)+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE), '_', ps1, 'X', ps2, '_FULL.jpg'));

            if ((nnz(B)/prod(size(B)) > PERCENT_BLACK) | (n == 1))
                imwrite(mat2gray(B), fn, 'jpg');
                %Next 3 lines insert bounding box to matrix and save file
                %IC([rect(2) (rect(2)+1) (rect(2)+rect(4)-1) (rect(2)+rect(4))],rect(1):(rect(1)+rect(3))) = 6000;
                %IC((rect(2)+1):(rect(2)+rect(4)-1),[rect(1) (rect(1)+1) (rect(1)+rect(3)-1) (rect(1)+rect(3))]) = 6000;
                %imwrite(mat2gray(IC), fn_full, 'jpg');
            end
            yinc = yinc + SAMPLE_SQUARE;
            if (rect(4) + 1) <= yinc
                yinc = 0;
                xinc = xinc + SAMPLE_SQUARE;
            end
        end 
        
        cnt = cnt + 1;
    end

  
 
