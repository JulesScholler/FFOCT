function [dataOut, handles] = oct_2phases(handles)

global SignalDAQ acq_state
acq_state=1;

handles.exp.FramesPerTrigger=2*handles.octCam.Naccu;
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
[data,handles.save.timeOCT,~]=getdata(handles.octCam.vid,handles.exp.FramesPerTrigger,'double');
dataOut=abs(mean(data(:,:,1,1:2:2*handles.octCam.Naccu),4)-mean(data(:,:,1,2:2:2*handles.octCam.Naccu),4));

stop(handles.octCam.vid);
stop(handles.DAQ.s);
acq_state=0;