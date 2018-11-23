function quitgui(handles)
% Function to exit the GUI and close properly every opened objects.

if isfield(handles,'octCam')
    if(isrunning(handles.octCam.vid))
        stop(handles.octCam.vid);
        stop(handles.DAQ.s);
        daq_output_zero(handles)
    end
    delete(handles.octCam.vid);
end

if isfield(handles,'motors')
    if(strcmp(handles.motors.port.Status,'open'))
        fclose(handles.motors.port);
    end
end

if isfield(handles,'DAQ')
    stop(handles.DAQ.s);
    delete(handles.DAQ.lh);
end

if isfield(handles,'fluoCam')
    if(isrunning(handles.fluoCam.vid))
        stop(handles.fluoCam.vid);
        stop(handles.DAQ.s);
        daq_output_zero(handles);
    end
    delete(handles.fluoCam.vid);
end

if isfield(handles,'SDOCT')
    if(libisloaded('SpectralRadar'))
        if exist('handles.SDOCT.ScanPattern', 'var')
            calllib('SpectralRadar','clearScanPattern', handles.SDOCT.ScanPattern);
        end
        calllib('SpectralRadar','clearData', handles.SDOCT.Data);
        calllib('SpectralRadar','clearRawData', handles.SDOCT.RawData);
        calllib('SpectralRadar','closeProcessing', handles.SDOCT.Proc);
        calllib('SpectralRadar','closeProbe', handles.SDOCT.Probe);
        calllib('SpectralRadar','closeDevice', handles.SDOCT.Dev);
        clear handles.SDOCT
        guidata(hObject, handles);
        unloadlibrary('SpectralRadar');
    end
end

fprintf('The program has exited properly.\n');

close all
clear all