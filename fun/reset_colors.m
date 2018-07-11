function handles = reset_colors(handles)

% fmin = min(handles.exp.dffoct.Ht(:));
% fmax = max(handles.exp.dffoct.Ht(:));
% smin = min(handles.exp.dffoct.St(:));
% smax = max(handles.exp.dffoct.St(:));

Vf = handles.exp.dffoct.Vt;
Vf(handles.exp.dffoct.Vt>handles.exp.dffoct.Vmax) = handles.exp.dffoct.Vmax;
Vf = rescale(Vf,0,1);

Sf = handles.exp.dffoct.St;
% handles.exp.dffoct.dfmin = handles.exp.dffoct.Smin*(smax-smin)+fmin;
% handles.exp.dffoct.dfmax = handles.exp.dffoct.Smax*(smax-smin)+fmin;
Sf = rescale(Sf, 0, 0.95);
Sf(Sf>handles.exp.dffoct.Smax) = handles.exp.dffoct.Smax;
Sf(Sf<handles.exp.dffoct.Smin) = handles.exp.dffoct.Smin;
Sf = rescale(-Sf, 0, 0.95);


Hf = imgaussfilt(rescale(handles.exp.dffoct.Ht,0,1),4);
% handles.exp.dffoct.fmin = handles.exp.dffoct.Hmin*(fmax-fmin)+fmin;
% handles.exp.dffoct.fmax = handles.exp.dffoct.Hmax*(fmax-fmin)+fmin;
% Hf(Hf<handles.exp.dffoct.Hmin) = handles.exp.dffoct.Hmin;
% Hf(Hf>handles.exp.dffoct.Hmax) = handles.exp.dffoct.Hmax;
Hf = rescale(Hf,0,0.66);
Hf(Hf<handles.exp.dffoct.Hmin) = handles.exp.dffoct.Hmin;
Hf(Hf>handles.exp.dffoct.Hmax) = handles.exp.dffoct.Hmax;
Hf = rescale(-Hf,0,0.66);

dffoct_hsv(:,:,1) = Hf;
dffoct_hsv(:,:,2) = Sf;
dffoct_hsv(:,:,3) = Vf;

dffoct = hsv2rgb(dffoct_hsv);
handles=drawInGUI(dffoct,6,handles);
% colormap = build_colormap(handles);
% figure(1)
% imshow(colormap)