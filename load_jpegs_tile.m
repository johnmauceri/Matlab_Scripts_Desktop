dirSource = 'C:\Users\John Mauceri\DICOM_TEST\crop_katie_91_to_118'; 
dirDest = 'C:\Users\John Mauceri\DICOM_TEST\crop_katie_91_to_118\out';

SAMPLE_SQUARE = 100;
TILE_SPACING = 10;
MAX_NUM_TILES = 10;
PERCENT_BLACK = 0.5;

files = dir(fullfile(dirSource, '*.jpg'));

cnt = 1;
for file = files'
    I = imread(fullfile(dirSource,file.name)); 
    A = I(:,:,1);
    [m,n] = size(A);
    rect = zeros(1, 4);
    %figure
    %imagesc(A);
    %colormap gray;
    
    ts = TILE_SPACING;
    while (1 == 1)
        tmp = (floor((n - SAMPLE_SQUARE)/ts)+1) * (floor((m - SAMPLE_SQUARE)/ts)+1);
        if (tmp <= MAX_NUM_TILES) break; end;
        ts = ts + 1;
    end
    
    for i = 1: ts: n - SAMPLE_SQUARE
        for j = 1: ts: m - SAMPLE_SQUARE
            rect(1) = i;
            rect(2) = j;
            rect(3) = SAMPLE_SQUARE;
            rect(4) = SAMPLE_SQUARE;
            B = imcrop(A, rect);
            %figure
            %imagesc(B);
            %colormap gray;
        
            fn = fullfile(dirDest, strcat('Tile', int2str(cnt), '_', int2str(i), '_', int2str(j), '.jpg'));
            if ((nnz(B)/prod(size(B)) > PERCENT_BLACK) | ((i * j) == 1))
               imwrite(mat2gray(B), fn, 'jpg');
            end
        end
    end 
    cnt = cnt + 1;
end
