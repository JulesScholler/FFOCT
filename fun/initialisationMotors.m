function handles=initialisationMotors(handles)
% This functions initiate and sets the configuration with the Zaber motors.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Zaber Motors Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if handles.gui.mode == 1 % FFOCT + Fluo
    handles.motors.port = serial('com17','BaudRate',9600);
    fopen(handles.motors.port);
    handles.motors.protocol=Zaber.Protocol.detect(handles.motors.port);
    handles.motors.sample = Zaber.BinaryDevice.initialize(handles.motors.protocol, 4);
    handles.motors.ref = Zaber.BinaryDevice.initialize(handles.motors.protocol, 3);
    handles.motors.RefMode=get(handles.menuRefMotor,'Value');
    handles.motors.SampleMode=get(handles.menuSampleMotor,'Value');
elseif handles.gui.mode == 2 % FFOCT + SDOCT
    
elseif handles.gui.mode == 3 % FFOCT inverse
    handles.motors.port = serial('com13','BaudRate',9600);
    fopen(handles.motors.port);
    handles.motors.protocol=Zaber.Protocol.detect(handles.motors.port);
    handles.motors.sample = Zaber.BinaryDevice.initialize(handles.motors.protocol, 1);
    handles.motors.ref = Zaber.BinaryDevice.initialize(handles.motors.protocol, 2);
    handles.motors.RefMode=get(handles.menuRefMotor,'Value');
    handles.motors.SampleMode=get(handles.menuSampleMotor,'Value');
end