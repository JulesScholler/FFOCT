function [dataOut, handles] = oct_direct(handles)

global SignalDAQ acq_state
acq_state=1;

handles.exp.FramesPerTrigger=handles.octCam.Naccu;
set(handles.octCam.vid, 'FramesPerTrigger', handles.exp.FramesPerTrigger, 'LoggingMode', 'memory');
handles=AnalogicSignalOCT(handles);
if ~isrunning(handles.octCam.vid)
    start(handles.octCam.vid);
    trigger(handles.octCam.vid); % Manually initiate data logging.
end
if ~handles.DAQ.s.IsRunning
    queueOutputData(handles.DAQ.s,SignalDAQ);
    startBackground(handles.DAQ.s);
end
wait(handles.octCam.vid,5*handles.exp.FramesPerTrigger)
[dataOut,handles.save.timeOCT,~]=getdata(handles.octCam.vid,handles.exp.FramesPerTrigger,'double');

stop(handles.octCam.vid);
stop(handles.DAQ.s);
acq_state=0;