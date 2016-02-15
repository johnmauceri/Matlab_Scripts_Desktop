file = 'C:\Users\John Mauceri\Desktop\M00008_42604732_t3_20150221_100830_R_MLO_Cancer_R_Cancer_oval-mass_Invasive-ductal-carcinoma_ct_0_dns_2.dcm.jpg';
I=imread(file);



[xy_long max_angl min_angl] = muscle_finder(I, 'TEST', 1);
max_len = xy_long(1,1);
if (max_len == 0)
    display('Error Could not find Muscle in file:', file);
    muscle_angl = 0;
else
    muscle_angl = atan((xy_long(1,2)-xy_long(2,2))/(xy_long(1,1)-xy_long(2,1)))*180/pi;
end
