function [dataOut, handles] = oct_4phases(handles)

global SignalDAQ acq_state
acq_state=1;

handles.exp.FramesPerTrigger=4*handles.octCam.Naccu;
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
I1=mean(data(:,:,1,1:4:4*handles.octCam.Naccu),4);
I2=mean(data(:,:,1,2:4:4*handles.octCam.Naccu),4);
I3=mean(data(:,:,1,3:4:4*handles.octCam.Naccu),4);
I4=mean(data(:,:,1,4:4:4*handles.octCam.Naccu),4);
dataOut=0.5*sqrt((I4-I2).^2+(I1-I3).^2);
% dataOut(:,:,1)=I1;
% dataOut(:,:,1)=I2;
% dataOut(:,:,1)=I3;
% dataOut(:,:,1)=I4;


stop(handles.octCam.vid);
stop(handles.DAQ.s);
acq_state=0;