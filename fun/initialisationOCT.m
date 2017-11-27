function handles=initialisationOCT(handles)
% This functions initiate and sets the configuration with the OCT camera
% and piezo.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.exp.piezoMode=1;
handles.exp.AmplPiezo=0;
handles.exp.PhiPiezo=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  OCT Camera Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.octCam.vid = videoinput('bitflow', 1, 'C:\Users\User1\Desktop\ConfigCamOlivier\Ctn\Adimec-Quartz-2A750-Mono triggered.bfml');
handles.octCam.src=getselectedsource(handles.octCam.vid);

set(handles.octCam.vid, 'TriggerRepeat', 0);
triggerconfig(handles.octCam.vid, 'Manual');
set(handles.octCam.vid, 'FramesPerTrigger', 1, 'LoggingMode', 'memory');
set(handles.octCam.vid, 'Timeout', 25);
set(handles.octCam.vid, 'TimerPeriod', 0.1);
handles.octCam.FcamOCT=20;
handles.octCam.ExpTime=10; % ms
handles.octCam.Naccu=1;
handles.octCam.X0=0;
handles.octCam.Y0=0;
handles.octCam.Nx=1440;
handles.octCam.Ny=1440;
set(handles.octCam.vid,'ROIPosition',[handles.octCam.X0 handles.octCam.Y0 handles.octCam.Nx handles.octCam.Ny]);

handles.octCam.param=get(handles.octCam.src);

handles.octCam.ReadoutTime=12.5*10^(-6)*(handles.octCam.Ny*(handles.octCam.Nx/2+8)+8);%ReadoutTime in ms ( d'après le manuel PhotonFocus)
handles.octCam.AddTime=1/128*(handles.octCam.ReadoutTime+0.001375)-(handles.octCam.ExpTime+0.0013)*heaviside(1/128*(handles.octCam.ReadoutTime+0.001375)-(handles.octCam.ExpTime+0.0013));% Nul si <0
handles.octCam.FrameTime=max(handles.octCam.ExpTime+0.076,handles.octCam.ReadoutTime+min(0.476,handles.octCam.ExpTime+0.0769))+handles.octCam.AddTime;%Approximatively measured ... (see calculframeRate.xls)