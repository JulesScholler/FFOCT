function [fluo,handles]=acqFluozStack(handles)
% Function to acquire fluo only images. Parameters are specified into the
% GUI and carried here by handles struct.

global acq_state SignalDAQ
acq_state=1;

set(handles.fluoCam.vid, 'TriggerFrameDelay', 2) % We leave the first 10 frames because the camera is not stable

set(handles.fluoCam.vid, 'FramesPerTrigger', handles.fluoCam.Naccu, 'LoggingMode', 'memory');
handles=AnalogicSignalOCT(handles);
if ~isrunning(handles.fluoCam.vid)
    start(handles.fluoCam.vid);
end
if ~handles.DAQ.s.IsRunning
    queueOutputData(handles.DAQ.s,SignalDAQ);
    startBackground(handles.DAQ.s);
end
wait(handles.fluoCam.vid,handles.fluoCam.Naccu*5)
daq_output_zero(handles)
[data,handles.save.timeFluo]=getdata(handles.fluoCam.vid,handles.fluoCam.Naccu,'double');
stop(handles.fluoCam.vid);
fluo=squeeze(mean(data,4));

set(handles.fluoCam.vid, 'TriggerFrameDelay', 0)

move=round(handles.motors.sample.Units.positiontonative(handles.save.zStackStep*1e-6)*5);
handles.motors.sample.moverelative(move);
pause(5)

acq_state=0;