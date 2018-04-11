function [dataOut, handles] = fluo_direct(handles)


global acq_state SignalDAQ
acq_state=1;

set(handles.fluoCam.vid, 'FramesPerTrigger', handles.fluoCam.Naccu*handles.save.Nfluo, 'LoggingMode', 'memory');
handles=AnalogicSignalOCT(handles);
if ~isrunning(handles.fluoCam.vid)
    start(handles.fluoCam.vid);
end
if ~handles.DAQ.s.IsRunning
    queueOutputData(handles.DAQ.s,SignalDAQ);
    startBackground(handles.DAQ.s);
end
wait(handles.fluoCam.vid,handles.fluoCam.Naccu*handles.save.Nfluo*5)
[dataOut,handles.save.timeFluo]=getdata(handles.fluoCam.vid,handles.fluoCam.Naccu*handles.save.Nfluo,'double');
stop(handles.octCam.vid);

acq_state=0;