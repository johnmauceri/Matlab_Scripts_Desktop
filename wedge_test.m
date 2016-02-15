%INPUTS to go CC to MLO
filenameCC = 'C:\Users\John Mauceri\Desktop\Mstudy\M00001\M00001_42325391_t3_20140909_151941_R_CC_Cancer_Right_Cancer_Fine-pleomorphic-calcifications_DCIS---Intermediate-Grade_ct_1_dns_2.dcm';
filenameMLO = 'C:\Users\John Mauceri\Desktop\Mstudy\M00001\M00001_42325391_t3_20140909_152359_R_MLO_Cancer_Right_Cancer_Fine-pleomorphic-calcifications_DCIS---Intermediate-Grade_ct_1_dns_2.dcm';
XCC = 2077.;
YCC = 1476.;
Direction = 0; 
[lin, err] = CCMLO_wedge(filenameCC, filenameMLO, Direction, XCC, YCC)

%INPUTS to go MLO to CC
filenameCC = 'C:\Users\John Mauceri\Desktop\Mstudy\M00001\M00001_42325391_t3_20140909_151941_R_CC_Cancer_Right_Cancer_Fine-pleomorphic-calcifications_DCIS---Intermediate-Grade_ct_1_dns_2.dcm';
filenameMLO = 'C:\Users\John Mauceri\Desktop\Mstudy\M00001\M00001_42325391_t3_20140909_152359_R_MLO_Cancer_Right_Cancer_Fine-pleomorphic-calcifications_DCIS---Intermediate-Grade_ct_1_dns_2.dcm';
XMLO = 1843.;
YMLO = 1923.;
Direction = 1; 
[lin, err] = CCMLO_wedge(filenameCC, filenameMLO, Direction, XMLO, YMLO)



%INPUTS to go CC to MLO
filenameCC = 'C:\Users\John Mauceri\Desktop\Mstudy\M00002\M00002_42295304_t3_20140902_140237_L_CC_Cancer_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---High-Grade_ct_1_dns_3.dcm';
filenameMLO = 'C:\Users\John Mauceri\Desktop\Mstudy\M00002\M00002_42295304_t3_20140902_140413_L_MLO_Cancer_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---High-Grade_ct_1_dns_3.dcm';
XCC = 2714.;
YCC = 1160.;
Direction = 0; 
[lin, err] = CCMLO_wedge(filenameCC, filenameMLO, Direction, XCC, YCC)

%INPUTS to go MLO to CC
filenameCC = 'C:\Users\John Mauceri\Desktop\Mstudy\M00002\M00002_42295304_t3_20140902_140237_L_CC_Cancer_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---High-Grade_ct_1_dns_3.dcm';
filenameMLO = 'C:\Users\John Mauceri\Desktop\Mstudy\M00002\M00002_42295304_t3_20140902_140413_L_MLO_Cancer_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---High-Grade_ct_1_dns_3.dcm';
XMLO = 2377.;
YMLO = 1529.;
Direction = 1; 
[lin, err] = CCMLO_wedge(filenameCC, filenameMLO, Direction, XMLO, YMLO)


%NOTE M00004 Has flip issues I = fliplr(I); !!!!!!!!!!!!!!!!!!!!!!!!!!!!

%INPUTS to go CC to MLO
filenameCC = 'C:\Users\John Mauceri\Desktop\Mstudy\M00004\M00004_42352896_t3_20140815_102547_L_CC_Cancer_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---Intermediate-Grade_ct_1_dns_3.dcm';
filenameMLO = 'C:\Users\John Mauceri\Desktop\Mstudy\M00004\M00004_42352896_t3_20140815_102630_L_MLO_Cancer_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---Intermediate-Grade_ct_1_dns_3.dcm';
XCC = 1885.;
YCC = 2049.;
Direction = 0; 
[lin, err] = CCMLO_wedge(filenameCC, filenameMLO, Direction, XCC, YCC)

%INPUTS to go MLO to CC
filenameCC = 'C:\Users\John Mauceri\Desktop\Mstudy\M00004\M00004_42352896_t3_20140815_102547_L_CC_Cancer_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---Intermediate-Grade_ct_1_dns_3.dcm';
filenameMLO = 'C:\Users\John Mauceri\Desktop\Mstudy\M00004\M00004_42352896_t3_20140815_102630_L_MLO_Cancer_Left_Cancer_Fine-pleomorphic-calcifications_DCIS---Intermediate-Grade_ct_1_dns_3.dcm';
XMLO = 1913.;
YMLO = 2099.;
Direction = 1; 
[lin, err] = CCMLO_wedge(filenameCC, filenameMLO, Direction, XMLO, YMLO)