function handles=initialisationDAQ(handles)
% This functions initiate and sets the configuration with the DAQ.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DAQ Opening
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.DAQ.s=daq.createSession('ni');
handles.DAQ.s.IsContinuous = true;
handles.DAQ.s.IsNotifyWhenScansQueuedBelowAuto=true;
handles.DAQ.s.Rate = 100e3;

handles.DAQ.lh=addlistener(handles.DAQ.s,'DataRequired',@queueMoreData);

handles.exp.SignalTest=[zeros(handles.DAQ.s.Rate,1) zeros(handles.DAQ.s.Rate,1) zeros(handles.DAQ.s.Rate,1)];

addAnalogOutputChannel(handles.DAQ.s,'Dev1','ao5','Voltage'); % Piezo Ref arm OCT
addAnalogOutputChannel(handles.DAQ.s,'Dev1','ao6','Voltage'); % Trigger Camera OCT
addAnalogOutputChannel(handles.DAQ.s,'Dev1','ao0','Voltage'); % Trigger camera Fluo (not used for now)
addAnalogOutputChannel(handles.DAQ.s,'Dev1','ao1','Voltage'); % Illumnitation