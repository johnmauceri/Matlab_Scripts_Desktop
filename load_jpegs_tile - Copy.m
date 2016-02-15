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
    rect(1) = 1;
    rect(2) = 1;
    rect(3) = n;
    rect(4) = m;
   
    B = imcrop(A, rect);
    %figure
    %imagesc(B);
    %colormap gray;
    
    C = im2col(B, [SAMPLE_SQUARE SAMPLE_SQUARE], 'sliding');   
    %C = im2colstep(B, [SAMPLE_SQUARE SAMPLE_SQUARE], [10 10]);
    sz= size(C);

    ts = TILE_SPACING;
    if ((sz(2) / TILE_SPACING) > MAX_NUM_TILES) 
        ts = ceil(sz(2) / MAX_NUM_TILES);
    end
    for n = 1: ts: sz(2)
        D = reshape(C(:,n), SAMPLE_SQUARE, SAMPLE_SQUARE);
        %figure
        %imagesc(D);
        %colormap gray;
        
        fn = fullfile(dirDest, strcat('Tile',  int2str(cnt), '_', int2str(n), '.jpg'));
        if ((nnz(D)/prod(size(D)) > PERCENT_BLACK) | (n == 1))
            imwrite(mat2gray(D), fn, 'jpg');
        end
    end 
            
    cnt = cnt + 1;
end
