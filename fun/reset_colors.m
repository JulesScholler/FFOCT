function handles = reset_colors(handles)


Vf = handles.exp.dffoct.Vt;
Vf(handles.exp.dffoct.Vt>handles.exp.dffoct.Vmax) = handles.exp.dffoct.Vmax;
Vf = rescale(Vf,0,1);

Sf = handles.exp.dffoct.St;
Sf = rescale(Sf, 0, 0.95);
Sf(Sf>handles.exp.dffoct.Smax) = handles.exp.dffoct.Smax;
Sf(Sf<handles.exp.dffoct.Smin) = handles.exp.dffoct.Smin;
Sf = rescale(-Sf, 0, 0.95);

Hf = imgaussfilt(rescale(handles.exp.dffoct.Ht,0,1),4);
Hf = rescale(Hf,0,0.66);
Hf(Hf<handles.exp.dffoct.Hmin) = handles.exp.dffoct.Hmin;
Hf(Hf>handles.exp.dffoct.Hmax) = handles.exp.dffoct.Hmax;
Hf = rescale(-Hf,0,0.66);

dffoct_hsv(:,:,1) = Hf;
dffoct_hsv(:,:,2) = Sf;
dffoct_hsv(:,:,3) = Vf;

dffoct = hsv2rgb(dffoct_hsv);
handles=drawInGUI(dffoct,6,handles);
