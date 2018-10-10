function [dataOut, handles] = oct_5phases(handles)

global SignalDAQ acq_state
acq_state=1;

handles.exp.FramesPerTrigger=10*handles.octCam.Naccu*handles.save.Noct;
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
wait(handles.octCam.vid,handles.exp.FramesPerTrigger)
[data,handles.save.timeOCT]=getdata(handles.octCam.vid,handles.exp.FramesPerTrigger,'double');
stop(handles.octCam.vid);
stop(handles.DAQ.s);
I1=double(mean(data(:,:,1,1:10:end),4)+mean(data(:,:,1,10:10:end),4))/2;
I2=double(mean(data(:,:,1,2:10:end),4)+mean(data(:,:,1,9:10:end),4))/2;
I3=double(mean(data(:,:,1,3:10:end),4)+mean(data(:,:,1,8:10:end),4))/2;
I4=double(mean(data(:,:,1,4:10:end),4)+mean(data(:,:,1,7:10:end),4))/2;
I5=double(mean(data(:,:,1,5:10:end),4)+mean(data(:,:,1,6:10:end),4))/2;
% dataOut(:,:,1)=mean(data(:,:,1,1:10:end),4);
% dataOut(:,:,2)=mean(data(:,:,1,2:10:end),4);
% dataOut(:,:,3)=mean(data(:,:,1,3:10:end),4);
% dataOut(:,:,4)=mean(data(:,:,1,4:10:end),4);
% dataOut(:,:,5)=mean(data(:,:,1,5:10:end),4);
% dataOut(:,:,6)=mean(data(:,:,1,6:10:end),4);
% dataOut(:,:,7)=mean(data(:,:,1,7:10:end),4);
% dataOut(:,:,8)=mean(data(:,:,1,8:10:end),4);
% dataOut(:,:,9)=mean(data(:,:,1,9:10:end),4);
% dataOut(:,:,10)=mean(data(:,:,1,10:10:end),4);

dataOut=sqrt(4*(I2-I4).^2+(-I1+2*I3-I5).^2);
% imPhase=angle(2*(I2-I4) + 1i*(-I1+2*I3-I5));

stop(handles.octCam.vid);
stop(handles.DAQ.s);
acq_state=0;