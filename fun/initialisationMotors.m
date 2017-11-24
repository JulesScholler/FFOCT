function handles=initialisationMotors(handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Zaber Motors Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.motors.port = serial('com7','BaudRate',9600);
fopen(handles.motors.port);
handles.motors.protocol=Zaber.Protocol.detect(handles.motors.port);
handles.motors.sample = Zaber.BinaryDevice.initialize(handles.motors.protocol, 4);
handles.motors.ref = Zaber.BinaryDevice.initialize(handles.motors.protocol, 3);
handles.motors.RefMode=get(handles.menuRefMotor,'Value');
handles.motors.SampleMode=get(handles.menuSampleMotor,'Value');