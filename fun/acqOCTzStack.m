function [dataOut,handles]=acqOCTzStack(handles,j)
% Funciton to acquire OCT only images for zStack. Each plane is recorded as the third dimension in
% a 3D array and saved in a multi-dimensionnal tiff file. Parameters are specified into the
% GUI and carried here by handles struct. OCT trigger is done by the
% National Instrument DAQ in order to synchronize the piezo and the camera.

set(handles.octCam.vid, 'TriggerFrameDelay', 10) % We leave the first 10 frames because the camera is not stable
switch handles.exp.piezoMode
    case 1 % Direct image only for zStack
        [dataOut, handles] = oct_direct(handles);
        saveParameters(handles)
    case 2 % Tomo image for zStack
        [dataOut, handles] = oct_2phases(handles);
        saveParameters(handles)
    case 3 % 4 phase imaging
        [dataOut, handles] = oct_4phases(handles);
        saveParameters(handles)
    case 4
    case 5
    case 6 % DFFOCT + tomo
        handles.exp.piezoMode=1;
        [dffoct, handles]=oct_direct(handles);
        if handles.save.direct
            saveAsTiff(dffoct,sprintf('dffoct_plane_%d',j),'adimec',handles)
        end
        saveParameters(handles)
        Naccu=handles.octCam.Naccu;
        handles.octCam.Naccu=5;
        handles.exp.piezoMode=2;
        [dataOut, handles]=oct_2phases(handles);
        handles.exp.piezoMode=6;
        handles.octCam.Naccu=Naccu;
end
set(handles.octCam.vid, 'TriggerFrameDelay', 0)