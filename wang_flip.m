

I = dicomread('C:\Users\John Mauceri\Desktop\Mstudy2\M00078\M00078_42290263_t3_20140717_085454_L_LM_Cancer_L_Cancer_focal-asymmetry_Invasive-lobular-carcinoma_ct_0_dns_3.dcm');
figure; imagesc(I); colormap gray;
INFO = dicominfo('C:\Users\John Mauceri\Desktop\Mstudy2\M00078\M00078_42290263_t3_20140717_085454_L_LM_Cancer_L_Cancer_focal-asymmetry_Invasive-lobular-carcinoma_ct_0_dns_3.dcm');
if (INFO.PatientOrientation(1) == 'A')
    I = fliplr(I);
end
figure; imagesc(I); colormap gray;



