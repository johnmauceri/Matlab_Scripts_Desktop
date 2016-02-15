dirSource = 'C:\Users\John Mauceri\DICOM_TEST\crop_katie_91_to_118'; 
dirDest = 'C:\Users\John Mauceri\DICOM_TEST\crop_katie_91_to_118\out';

SAMPLE_SQUARE = 100;
TILE_SPACING = 10;
MAX_NUM_TILES = 30;
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
    
    tsi = TILE_SPACING;
    tsj = TILE_SPACING;
    if ((n / TILE_SPACING) > MAX_NUM_TILES) 
        tsi = ceil(n / MAX_NUM_TILES^0.5);
    end
    if ((m / TILE_SPACING) > MAX_NUM_TILES) 
        tsj = ceil(m / MAX_NUM_TILES^0.5);
    end
    tmp = (floor((n - SAMPLE_SQUARE)/tsi)+1) * (floor((m - SAMPLE_SQUARE)/tsj)+1);
    for i = 1: tsi: n - SAMPLE_SQUARE
        for j = 1: tsj: m - SAMPLE_SQUARE
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
