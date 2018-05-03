function daq_output_zero(handles)
% This functions forces the DAQ to output 0V tension.

handles=AnalogicSignalOCT(handles);
if handles.DAQ.s.IsRunning
    stop(handles.DAQ.s);
end
queueOutputData(handles.DAQ.s,zeros(50000,5));
startBackground(handles.DAQ.s);
stop(handles.DAQ.s);
