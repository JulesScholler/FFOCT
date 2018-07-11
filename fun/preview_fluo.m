function handles = preview_fluo(handles)

handles.fluoCam.src_preview.E2ExposureTime = handles.fluoCam.ExpTime;
hImage=image(zeros(2160,2560),'Parent',handles.axesFluo);
preview(handles.fluoCam.vid_preview, hImage);