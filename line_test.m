%INPUTS to go CC to MLO
filenameCC = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Mstudy\Can1_1_RCC_M00001_t3_Q614.96_T0_X2032_Y1428_100X100_0.07X0.07_ORIG.jpg';
filenameMLO = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Mstudy\Can2_1_RMLO_M00001_t3_Q314.08_T0_X1777_Y1873_100X100_0.07X0.07_ORIG.jpg';
XCC = 2032.;
YCC = 1428.;
dirDest = 'C:\Users\John Mauceri\DICOM_TEST\DICOM_rect\Location5';
line = CC2MLO_line(filenameCC, filenameMLO, dirDest, XCC, YCC);
%Direction = 0; 

%{INPUTS to go MLO to CC
%filenameCC = 'C:\Users\John Mauceri\Desktop\Mstudy\M00001\M00001_42325391_t3_20140909_151941_R_CC_Cancer_Right_Cancer_Fine-pleomorphic-calcifications_DCIS---Intermediate-Grade_ct_1_dns_2.dcm';
%filenameMLO = 'C:\Users\John Mauceri\Desktop\Mstudy\M00001\M00001_42325391_t3_20140909_152359_R_MLO_Cancer_Right_Cancer_Fine-pleomorphic-calcifications_DCIS---Intermediate-Grade_ct_1_dns_2.dcm';
%XMLO = 1827.;
%YMLO = 1405.;
%Direction = 1; 
