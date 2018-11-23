function handles=clearCameras(handles)

if isfield(handles.octCam,'vid')
    if(isrunning(handles.octCam.vid))
        stop(handles.octCam.vid);
        stop(handles.DAQ.s);
        queueOutputData(handles.DAQ.s,SignalTest); % Est ce que je mettrais pas un signal continu plutôt?
        startBackground(handles.DAQ.s);
        stop(handles.DAQ.s)
    end
    delete(handles.octCam.vid);
    handles.octCam = rmfield(handles.octCam,'vid');
    handles.octCam = rmfield(handles.octCam,'src');
    set(handles.checkOCT,'Value',0)
    set(handles.panelOCTdirect,'Visible','off')
    set(handles.panelOCTtomo,'Visible','off')
end
if isfield(handles,'fluoCam')
    if(isrunning(handles.fluoCam.vid))
        stop(handles.fluoCam.vid);
        stop(handles.DAQ.s);
        queueOutputData(handles.DAQ.s,SignalTest); % Est ce que je mettrais pas un signal continu plutôt?
        startBackground(handles.DAQ.s);
        stop(handles.DAQ.s)
    end
    delete(handles.fluoCam.vid);
    set(handles.checkFluo,'Value',0)
    set(handles.panelFluo,'Visible','off')
end