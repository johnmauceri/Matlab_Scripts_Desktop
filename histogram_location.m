SourceM = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\Mstudy\hist_muscle_angle.txt'; 
SourceC = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\Mstudy\hist_camera_angle.txt'; 
SourceA = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_LOCATION\Mstudy\asymmetry.txt'; 


FIDM = fopen(SourceM, 'rt');
FIDC = fopen(SourceC, 'rt');
FIDA = fopen(SourceA, 'rt');
fgetl(FIDM);
fgetl(FIDC);

M = textscan(FIDM,'%s  %f\n');
C = textscan(FIDC,'%s  %f\n');  
A = textscan(FIDA,'%f\n');

muscle_angle = abs(M{2});
camera_angle = abs(C{2});
asymmetry = A{1};

figure
bins = 100;
hist(muscle_angle, bins);
title('Muscle Angle');

figure
bins = 100;
hist(muscle_angle-camera_angle, bins);
title('Muscle Angle - Camera Angle');
  
figure
bins = 100;
hist(camera_angle, bins);
title('Camera Angle');

figure
bins = 10;
hist(asymmetry, bins);
title('Asymmetry');
 
fclose(FIDM);
fclose(FIDC);
fclose(FIDA);