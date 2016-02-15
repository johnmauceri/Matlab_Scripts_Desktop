function test
filenameCC  = 'C:\Users\John Mauceri\Desktop\M00001_42325391_t3_05365_151941_R__CC_Cancer_R_calcs_N_2.dcm';
filenameMLO = 'C:\Users\John Mauceri\Desktop\M00001_42325391_t3_05365_152359_R__MLO_Cancer_R_calcs_N_2.dcm';
direction   = 0;
x           = double(2456);
y           = double(1896);
wedges      = find_wedges(filenameCC,filenameMLO,direction,x,y);
end