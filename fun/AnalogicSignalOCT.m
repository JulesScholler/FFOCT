function handles=AnalogicSignalOCT(handles) % Ne fonctionne que si (s.IsNotifyWhenScansQueuedBelowAuto=true); The only constraint is that the signal should be at least long of fs points
% This function generates the analogic trigger to synchronize the piezo and
% the OCT camera. Parameters for framerate and exposure time are given
% through the handles struct.

%A Camera signal will be generated continuously (To avoid that the camera shuts down). If unprecised, the piezo
%and the illumination are also generated continuously. However, for the
%sake of reducing Piezo work, or reducing illumination, one can specify
%the number of camera images for which the piezo and the illumination
%should be active.

global SignalDAQ

if(handles.DAQ.s.IsRunning)
    stop(handles.DAQ.s);
end

% On définit la fréquence du Piezo OCT
switch handles.exp.piezoMode
    case 1
        handles.exp.FPiezOCT=handles.octCam.FcamOCT;
        handles.octCam.Ncam=ceil(handles.octCam.FcamOCT);
    case 2
        handles.exp.FPiezOCT=handles.octCam.FcamOCT/2;
        handles.octCam.Ncam=2*ceil(handles.exp.FPiezOCT);
    case 3
        handles.exp.FPiezOCT=handles.octCam.FcamOCT/4;
        handles.octCam.Ncam=4*ceil(handles.exp.FPiezOCT);
    case 4
        handles.exp.FPiezOCT=handles.octCam.FcamOCT/5;
        handles.octCam.Ncam=5*ceil(handles.exp.FPiezOCT);
    case 5
        handles.exp.FPiezOCT=handles.octCam.FcamOCT;
        handles.octCam.Ncam=ceil(handles.octCam.FcamOCT);
end

% Trigger signals definition
handles.exp.CamOCT = zeros(floor(handles.DAQ.s.Rate* handles.octCam.Ncam/ handles.octCam.FcamOCT),1);
handles.exp.PiezoOCT=zeros(floor(handles.DAQ.s.Rate* handles.octCam.Ncam/ handles.octCam.FcamOCT),1);
handles.exp.CamFluo= zeros(floor(handles.DAQ.s.Rate* handles.octCam.Ncam/ handles.octCam.FcamOCT),1);
handles.exp.LedOCT= zeros(floor(handles.DAQ.s.Rate* handles.octCam.Ncam/ handles.octCam.FcamOCT),1);
handles.exp.LedFluo= zeros(floor(handles.DAQ.s.Rate* handles.octCam.Ncam/ handles.octCam.FcamOCT),1);

if handles.gui.oct
    for i =1:handles.octCam.Ncam %So that the signal last for 1 s.
        handles.exp.CamOCT(1+floor((i-1)*handles.DAQ.s.Rate/handles.octCam.FcamOCT+handles.DAQ.s.Rate*(1/(2*handles.octCam.FcamOCT)-handles.octCam.ExpTime/2000)):...
            floor((i-1)*handles.DAQ.s.Rate/handles.octCam.FcamOCT+handles.DAQ.s.Rate*(1/(2*handles.octCam.FcamOCT)+handles.octCam.ExpTime/2000)))=5; 
        %The signal is shifted of one value, so that the last value is 0.
    end
    handles.exp.CamOCT(end)=0;
    switch handles.exp.piezoMode
        case 4
            time=transpose(linspace(0,1,floor(handles.DAQ.s.Rate*handles.octCam.Ncam/handles.octCam.FcamOCT)));
            N_decalage=floor(mod(handles.exp.PhiPiezo,pi/2)/(2*pi)*handles.DAQ.s.Rate/handles.exp.FPiezOCT);
            Amp=sawtooth(2*pi*handles.octCam.FcamOCT/10*time,0.5);
            handles.exp.PiezoOCT(1+N_decalage:floor(handles.DAQ.s.Rate*handles.octCam.Ncam/handles.octCam.FcamOCT))=Amp(1:end-N_decalage)*handles.exp.AmplPiezo;
        case 3
            N_decalage=floor(mod(handles.exp.PhiPiezo,pi/2)/(2*pi)*handles.DAQ.s.Rate/handles.exp.FPiezOCT);
            Dec=(handles.exp.PhiPiezo-mod(handles.exp.PhiPiezo,pi/2))/(pi/2);
            %On veut que le trig caméra tombe au milieu du créneau du Piezo
            for i=1:handles.octCam.Ncam
                handles.exp.PiezoOCT(1+floor(i*handles.DAQ.s.Rate/handles.octCam.FcamOCT)-N_decalage:floor((i+1)*handles.DAQ.s.Rate/handles.octCam.FcamOCT)-N_decalage)=handles.exp.AmplPiezo*(3-mod((i+Dec),4))/3;
            end
            handles.exp.PiezoOCT(1:floor(handles.DAQ.s.Rate/handles.octCam.FcamOCT)-N_decalage)=handles.exp.AmplPiezo*(3-mod((Dec),4))/3;
            handles.exp.PiezoOCT=handles.exp.PiezoOCT(1:floor(handles.DAQ.s.Rate*handles.octCam.Ncam/handles.octCam.FcamOCT));
        case 2
            N_decalage=floor(mod(handles.exp.PhiPiezo,pi)/(2*pi)*handles.DAQ.s.Rate/handles.exp.FPiezOCT);
            Dec=(handles.exp.PhiPiezo-mod(handles.exp.PhiPiezo,pi))/(pi);
            for i=1:handles.octCam.Ncam
                handles.exp.PiezoOCT(1+floor(i*handles.DAQ.s.Rate/handles.octCam.FcamOCT)-N_decalage:floor((i+1)*handles.DAQ.s.Rate/handles.octCam.FcamOCT)-N_decalage)=handles.exp.AmplPiezo*(mod(i+1+Dec,2));
            end
            handles.exp.PiezoOCT(1:floor(handles.DAQ.s.Rate/handles.octCam.FcamOCT)-N_decalage)=handles.exp.AmplPiezo*(mod((Dec+1),2));
            handles.exp.PiezoOCT=handles.exp.PiezoOCT(1:floor(handles.DAQ.s.Rate*handles.octCam.Ncam/handles.octCam.FcamOCT));
        case 1
            % on ne fait rien :)
    end
end

if handles.gui.fluo
    handles.fluoCam.Ncam=ceil(handles.fluoCam.Fcam);
    for i =1:handles.fluoCam.Ncam % So that the signal last for 1 s.
        handles.exp.CamFluo(1+floor((i-1)*handles.DAQ.s.Rate/handles.fluoCam.Fcam+handles.DAQ.s.Rate*(1/(2*handles.fluoCam.Fcam)-handles.fluoCam.ExpTime/2000)):...
            floor((i-1)*handles.DAQ.s.Rate/handles.fluoCam.Fcam+handles.DAQ.s.Rate*(1/(2*handles.fluoCam.Fcam)+handles.fluoCam.ExpTime/2000)))=5;
        %The signal is shifted of one value, so that the last value is 0.
    end
    handles.exp.CamFluo(end)=0;
end

if handles.exp.illuminationEnabled
    switch handles.exp.illuminationMode
        case 1 % Triggered
            handles.exp.LedOCT=handles.exp.CamOCT/5*handles.exp.LedOCTPower/200;
            handles.exp.LedFluo=handles.exp.CamFluo/5*handles.exp.LedFluoPower/200;
        case 2 % Continuous
            handles.exp.LedOCT=ones(floor(handles.DAQ.s.Rate* handles.octCam.Ncam/ handles.octCam.FcamOCT),1)*handles.exp.LedOCTPower/200;
            handles.exp.LedFluo=ones(floor(handles.DAQ.s.Rate* handles.octCam.Ncam/ handles.octCam.FcamOCT),1)*handles.exp.LedFluoPower/200;
    end
end

SignalDAQ=[handles.exp.PiezoOCT,handles.exp.CamOCT,handles.exp.CamFluo,handles.exp.LedOCT,handles.exp.LedFluo];

% t=0:1/handles.DAQ.s.Rate:(length(SignalDAQ)-1)/handles.DAQ.s.Rate;
% figure
% plot(t,SignalDAQ)

end