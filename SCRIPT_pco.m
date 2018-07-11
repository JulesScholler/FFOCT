% vid = videoinput('pcocameraadaptor', 0, 'CameraLink');
% src = getselectedsource(vid);
% vid.FramesPerTrigger = 1;
% src.E1ExposureTime_unit = 'ms';
% src.E2ExposureTime = 100;
% param = get(src);
% preview(vid);


vid2 = videoinput('bitflow',1, 'Adimec-Quartz-2A750-Mono triggered.bfml');
src2=getselectedsource(vid2);
triggerconfig(vid2, 'immediate');
vid2.FramesPerTrigger = 1;
param2 = get(src2);
preview(vid2);
start(vid2);