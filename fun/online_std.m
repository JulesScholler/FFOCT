function [m2,M2]=online_std(data,M1,m1,n)
% Function that computes the new std given the previous std and the number
% of samples n. It uses a smart implementation to avoid numerical errors
% when computing sum of very great numbers.

if n==0
    m1=0.0;
    M1=0.0;
end
delta = data - m1;
m2 = m1 + delta./(n+1);
delta2 = data - m2;
M2 = M1 + delta.*delta2;
