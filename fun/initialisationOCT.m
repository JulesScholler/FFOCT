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

% External trig. for synchronous acquisition
handles.octCam.vid = videoinput('bitflow',1, 'Adimec-Quartz-2A750-Mono triggered.bfml');
handles.octCam.src=getselectedsource(handles.octCam.vid);
handles.octCam.vid.TriggerRepeat=0;
triggerconfig(handles.octCam.vid, 'Manual');
set(handles.octCam.vid, 'Timeout', 25);
set(handles.octCam.vid, 'TimerPeriod', 0.1);
handles.octCam.FcamOCT=20;
handles.octCam.ExpTime=10; % ms
handles.octCam.Naccu=1;
[dataOut, handles] = oct_2phases(handles);
handles.octCam.X0=1;
handles.octCam.Y0=1;
handles.octCam.Nx=size(dataOut,2);
handles.octCam.Ny=size(dataOut,1);
handles.octCam.xmin=ceil(handles.octCam.X0*handles.exp.imResize);
handles.octCam.ymin=ceil(handles.octCam.Y0*handles.exp.imResize);
handles.octCam.xmax=floor(handles.octCam.Nx*handles.exp.imResize);
handles.octCam.ymax=floor(handles.octCam.Ny*handles.exp.imResize);
% set(handles.octCam.vid,'ROIPosition',[handles.octCam.X0 handles.octCam.Y0 handles.octCam.Nx handles.octCam.Ny]); % Matlab ROI, not camera ROI.
handles.octCam.param=get(handles.octCam.src);
handles.octCam.ReadoutTime=12.5*10^(-6)*(handles.octCam.Ny*(handles.octCam.Nx/2+8)+8);
handles.octCam.AddTime=1/128*(handles.octCam.ReadoutTime+0.001375)-(handles.octCam.ExpTime+0.0013)*heaviside(1/128*(handles.octCam.ReadoutTime+0.001375)-(handles.octCam.ExpTime+0.0013));
handles.octCam.FrameTime=max(handles.octCam.ExpTime+0.076,handles.octCam.ReadoutTime+min(0.476,handles.octCam.ExpTime+0.0769))+handles.octCam.AddTime;

% Internal trig. for preview/asynchronous acquisition
% handles.octCam.vid_preview =  videoinput('bitflow', 1, 'TTLTrigger@Adimec-Quartz-2A750-Mono.bfml');
% handles.octCam.src_preview=getselectedsource(handles.octCam.vid_preview);
