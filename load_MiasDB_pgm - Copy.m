source = 'C:\Users\John Mauceri\Desktop\Mias_DB\data.txt'; 
dirDest = 'C:\Users\John Mauceri\Desktop\Mias_DB\out';
sourceData = 'C:\Users\John Mauceri\Desktop\Mias_DB\';

SAMPLE_SQUARE = 100;
PERCENT_BLACK = 0.5;
REDUCE_RECT_PCT = 0.25;

FID = fopen(source);
C = textscan(FID, '%s %s %s %s %f %f %f');
fclose(FID);

fname = C{1, 1};
filename = strcat(sourceData, C{1, 1}, '.pgm');
background_tissue = C{1, 2};
abnormality_class = C{1, 3};
severity_abnormality = C{1, 4};
X = C{1, 5};
Y = C{1, 6};
Y = 1024 - Y;
radius = C{1, 7};

cnt = 1;
for loop = filename'
     
    if (cell2mat(abnormality_class(cnt)) == 'NORM') 
        cnt = cnt + 1;
        continue; 
    end;
    file = num2str(cell2mat(loop));
    if ~exist(file)
        display('Error file not found.', file);
        continue
    end
    
    I = imread(file);
    %imagesc(I);
    %colormap gray;
        
    Xmin = X(cnt) - radius(cnt);
    Xmax = X(cnt) + radius(cnt);
    Ymin = Y(cnt) - radius(cnt);
    Ymax = Y(cnt) + radius(cnt);
    rect = zeros(1, 4);
    
    if ((Xmax - Xmin) < SAMPLE_SQUARE)
        rect(1) = X(cnt) - (SAMPLE_SQUARE / 2);
        rect(3) = SAMPLE_SQUARE - 1;
    elseif ((REDUCE_RECT_PCT * (Xmax - Xmin)) < SAMPLE_SQUARE)
        rect(1) = X(cnt) - (SAMPLE_SQUARE / 2);
        rect(3) = SAMPLE_SQUARE - 1;  
    else
        rect(1) = X(cnt) - (REDUCE_RECT_PCT * ((Xmax - Xmin) / 2));
        rect(3) = REDUCE_RECT_PCT * (Xmax - Xmin);
    end
        
    if ((Ymax - Ymin) < SAMPLE_SQUARE)
        rect(2) = Y(cnt) - (SAMPLE_SQUARE / 2);
        rect(4) = SAMPLE_SQUARE - 1;
    elseif ((REDUCE_RECT_PCT * (Ymax - Ymin)) < SAMPLE_SQUARE)
        rect(2) = Y(cnt) - (SAMPLE_SQUARE / 2);
        rect(4) = SAMPLE_SQUARE - 1;   
    else
        rect(2) = Y(cnt) - (REDUCE_RECT_PCT * ((Ymax - Ymin) / 2));
        rect(4) = REDUCE_RECT_PCT * (Ymax - Ymin);
    end
        
    rect = int64(rect);
    I = imcrop(I, rect);
    %figure
    %imagesc(I);
    %colormap gray;
    A = im2col(I, [SAMPLE_SQUARE SAMPLE_SQUARE], 'distinct');
    sz= size(A);
    
    xinc = 0;
    yinc = 0;
    for n = 1: sz(2)
        B = reshape(A(:,n), SAMPLE_SQUARE, SAMPLE_SQUARE);
        %figure
        %imagesc(B);
        %colormap gray;
        
        fn = fullfile(dirDest, strcat('Mias', '_', fname(cnt), '_', int2str(cnt), '_', int2str(n), '_', background_tissue(cnt) , '_', abnormality_class(cnt), '_', severity_abnormality(cnt), '_X', num2str(rect(1)+xinc), '_', 'Y', num2str(rect(2)+yinc), '_', num2str(SAMPLE_SQUARE), 'X', num2str(SAMPLE_SQUARE),'.jpg'));
            
        if ((nnz(B)/prod(size(B)) > PERCENT_BLACK) | (n == 1))
            imwrite(mat2gray(B), fn{1}, 'jpg');
        end
        yinc = yinc + SAMPLE_SQUARE;
        if (rect(4) + 1) <= yinc
            yinc = 0;
            xinc = xinc + SAMPLE_SQUARE;
        end
    end 
    cnt = cnt + 1;
end