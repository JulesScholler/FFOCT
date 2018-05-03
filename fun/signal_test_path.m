function [signal_test] = signal_test_path(path)
close all
clear all
signal_test = load(path);
signal_test = signal_test.c;
signal_test = signal_test';
figure
plot(signal_test)
end
