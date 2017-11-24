function handles=initialisationDAQ(handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DAQ Opening
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.DAQ.s=daq.createSession('ni'); % Cree la session
handles.DAQ.s.IsContinuous = true; %Enregistre tant qu'on ne l arrete pas manuellement
handles.DAQ.s.IsNotifyWhenScansQueuedBelowAuto=true; %Empeche de bugger si on met mois de fs/2 points. A chaque acquisition, on rentre le nombre de points necessaires de toute facon!
handles.DAQ.s.Rate = 100e3; % Fréquence d'échantillonnage max =800,000 sur la carte PCI-6722 classique. Il s'agit de la fréquence d'échantillonage par voie. DOnc 100.000 scans/s pour chacune des 4 voies

handles.DAQ.lh=addlistener(handles.DAQ.s,'DataRequired',@queueMoreData);

handles.exp.SignalTest=[zeros(handles.DAQ.s.Rate,1) zeros(handles.DAQ.s.Rate,1) zeros(handles.DAQ.s.Rate,1)];

addAnalogOutputChannel(handles.DAQ.s,'Dev1','ao5','Voltage');%Piezo Ref arm OCT
addAnalogOutputChannel(handles.DAQ.s,'Dev1','ao6','Voltage');%Trigger Camera OCT
addAnalogOutputChannel(handles.DAQ.s,'Dev1','ao0','Voltage');%Trigger camera Fluo