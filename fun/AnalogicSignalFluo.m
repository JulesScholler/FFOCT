function handles=AnalogicSignalFluo(handles) % Ne fonctionne que si (s.IsNotifyWhenScansQueuedBelowAuto=true); The only constraint is that the signal should be at least long of fs points
% This function generates an analogic trigger for the fluorescence camera.
% It is currently not used as we don't need strict synchronization between
% the fluorescence camera and the OCT camera.

%A Camera signal will be generated continuously (To avoid that the camera shuts down). If unprecised, the piezo
%and the illumination are also generated continuously. However, for the
%sake of reducing Piezo work, or reducing illumination, one can specify
%the number of camera images for which the piezo and the illumination
%should be active.

global SignalDAQ

if(handles.DAQ.s.IsRunning)
    stop(handles.DAQ.s);
end

handles.exp.Ncam=100; % Number of images to take per signal generated


% La durée du signal analogique est prise comme deux fois la période du
% piezo le plus "lent". Ensuite, on attendra une demi période avant et une
% après.

% n=round(fs/FPiezOCT); %In case it is not an integer. Normally, The frequencies have been calculated so that n is an integer, but it might prevent apporximation errors.

%In the worst case, n*Naccu points are required to have the entire signal.
%We add one n to be able to shift the signal with Ndecalage and another n
%to be sure that the signal comes back to 0 at the end.

handles.exp.dutyCycle=0.25;

for i=1:handles.exp.Ncam
    handles.exp.CamFluo(1+floor((i-1)*handles.DAQ.s.Rate/handles.fluoCam.Fcam)...
        +floor(handles.DAQ.s.Rate*(1/(2*handles.fluoCam.Fcam)-handles.fluoCam.ExpTime/2000))...
        :floor((i-1)*handles.DAQ.s.Rate/handles.fluoCam.Fcam)...
        +floor(handles.DAQ.s.Rate*(1/(2*handles.fluoCam.Fcam)-handles.fluoCam.ExpTime/2000))...
        +floor(handles.exp.dutyCycle*handles.DAQ.s.Rate/handles.fluoCam.Fcam))=5;
end
handles.exp.CamFluo(end)=0;

handles.exp.CamOCT=zeros(length(handles.exp.CamFluo),1);
handles.exp.PiezoOCT=zeros(length(handles.exp.CamFluo),1);

SignalDAQ=[handles.exp.PiezoOCT,handles.exp.CamOCT,handles.exp.CamFluo'];

end
