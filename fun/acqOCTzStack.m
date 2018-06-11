function [dataOut,handles]=acqOCTzStack(handles,j)
% Funciton to acquire OCT only images for zStack. Each plane is recorded as the third dimension in
% a 3D array and saved in a multi-dimensionnal tiff file. Parameters are specified into the
% GUI and carried here by handles struct. OCT trigger is done by the
% National Instrument DAQ in order to synchronize the piezo and the camera.

set(handles.octCam.vid, 'TriggerFrameDelay', 10) % We leave the first 10 frames because the camera is not stable
switch handles.exp.piezoMode
    case 1 % Direct image only for zStack
        [dataOut, handles] = oct_direct(handles);
        handles=drawInGUI(dataOut,1,handles);
        move=round(handles.motors.sample.Units.positiontonative(handles.save.zStackStep*1e-6)*5);
        handles.motors.sample.moverelative(move);
        pause(5)
        saveParameters(handles)
    case 2 % Tomo image for zStack
        [dataOut, handles] = oct_2phases(handles);
        handles=drawInGUI(dataOut,2,handles);
        move=round(handles.motors.sample.Units.positiontonative(handles.save.zStackStep*1e-6)*5);
        handles.motors.sample.moverelative(move);
        pause(5)
        saveParameters(handles)
    case 3 % 4 phase imaging
        [dataOut, handles] = oct_4phases(handles);
        handles=drawInGUI(dataOut,2,handles);
        move=round(handles.motors.sample.Units.positiontonative(handles.save.zStackStep*1e-6)*5);
        handles.motors.sample.moverelative(move);
        pause(5)
        saveParameters(handles)
    case 4
    case 5
    case 6 % DFFOCT + tomo
        % First take tome image with 5 accumulations
        Naccu=handles.octCam.Naccu;
        handles.octCam.Naccu=5;
        handles.exp.piezoMode=2;
        [dataOut, handles]=oct_2phases(handles);
        handles=drawInGUI(dataOut,2,handles);
        handles.octCam.Naccu=Naccu;
        
        % Then take DFFOCT and compute it
        handles.exp.piezoMode=1;
        [direct, handles]=oct_direct(handles);
        % Move before computation (don't need to pause afterwards)
        move=round(handles.motors.sample.Units.positiontonative(handles.save.zStackStep*1e-6)*5);
        handles.motors.sample.moverelative(move);
        [dffoct, handles]=dffoct_gpu(direct, handles);
        handles=drawInGUI(dffoct,6,handles);
        imwrite(dffoct,[handles.save.path '\' handles.save.t '\' sprintf('dffoct_plane_%d.tif',j)]);
        saveParameters(handles)
        
        if handles.save.allraw
            saveAsTiff(direct, [handles.save.path '\' handles.save.t '\' sprintf('dffoct_plane_%d',j)], 'adimec',handles);
        end
        % Put back the initial mode
        handles.exp.piezoMode=6;
end
set(handles.octCam.vid, 'TriggerFrameDelay', 0)