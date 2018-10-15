function handles=liveHolovibes(handles)

global SignalDAQ acq_state
acq_state=1;

handles=AnalogicSignalOCT(handles);

while acq_state
    if ~handles.DAQ.s.IsRunning
        queueOutputData(handles.DAQ.s,SignalDAQ);
        startBackground(handles.DAQ.s);
    end
end

stop(handles.DAQ.s);