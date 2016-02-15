
%INPUTS to go MLO to MLO
filename1 = 'C:\Users\John Mauceri\Desktop\Mstudy\M00002\M00002_42295304_t3_20140902_140413_L_MLO_Cancer_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---High-Grade_ct_1_dns_3.dcm';
filename2 = 'C:\Users\John Mauceri\Desktop\Mstudy\M00002\M00002_42295304_t3_20140902_141505_R_MLO_Benign_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---High-Grade_ct_1_dns_3.dcm';
X1 = 2377.;
Y1 = 1529.;
[X, Y, err] = time_lr_finder(filename1, filename2, X1, Y1)


%INPUTS to go MLO to MLO
filename1 = 'C:\Users\John Mauceri\Desktop\Mstudy\M00001\M00001_42325391_t3_20140909_152359_R_MLO_Cancer_Right_Cancer_Fine-pleomorphic-calcifications_DCIS---Intermediate-Grade_ct_1_dns_2.dcm';
filename2 = 'C:\Users\John Mauceri\Desktop\Mstudy\M00002\M00002_42295304_t3_20140902_140413_L_MLO_Cancer_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---High-Grade_ct_1_dns_3.dcm';
%Actual
X1 = 1843.;
Y1 = 1923.;

%Min
%X1 = 1972;
%Y1 = 2876.;

%Max
%X1 = 1322;
%Y1 = 1622.;

[X, Y, err] = time_lr_finder(filename1, filename2, X1, Y1)


%INPUTS to go CC to CC
filename1 = 'C:\Users\John Mauceri\Desktop\Mstudy\M00001\M00001_42325391_t3_20140909_151941_R_CC_Cancer_Right_Cancer_Fine-pleomorphic-calcifications_DCIS---Intermediate-Grade_ct_1_dns_2.dcm';
filename2 = 'C:\Users\John Mauceri\Desktop\Mstudy\M00002\M00002_42295304_t3_20140902_140237_L_CC_Cancer_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---High-Grade_ct_1_dns_3.dcm';
X1 = 2077.;

%Min
Y1 = 2615.;

%Max
Y1 = 491.;

%Actual
Y1 = 1476.;

[X, Y, err] = time_lr_finder(filename1, filename2, X1, Y1)



%INPUTS to go CC to CC
filename1 = 'C:\Users\John Mauceri\Desktop\Mstudy\M00002\M00002_42295304_t3_20140902_140237_L_CC_Cancer_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---High-Grade_ct_1_dns_3.dcm';
filename2 = 'C:\Users\John Mauceri\Desktop\Mstudy\M00002\M00002_42295304_t3_20140902_140135_R_CC_Benign_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---High-Grade_ct_1_dns_3.dcm';
X1 = 2714.;
Y1 = 1160.;
[X, Y, err] = time_lr_finder(filename1, filename2, X1, Y1)