function [mu] = circ_mean_adapted(alpha)
%
% mu = circ_mean(alpha, w)
%   Computes the mean direction for circular data.
%
%   Input:
%     alpha	sample of angles in radians
%     [w		weightings in case of binned angle data]
%     [dim  compute along this dimension, default is 1]
%
%     If dim argument is specified, all other optional arguments can be
%     left empty: circ_mean(alpha, [], dim)
%
%   Output:
%     mu		mean direction
%     ul    upper 95% confidence limit
%     ll    lower 95% confidence limit 
%
% PHB 7/6/2008
%
% References:
%   Statistical analysis of circular data, N. I. Fisher
%   Topics in circular statistics, S. R. Jammalamadaka et al. 
%   Biostatistical Analysis, J. H. Zar
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html

% compute  sum of cos and sin of angles
r = nansum(exp(1i*alpha),1);

% obtain mean by
mu = angle(r);

% rotate around colorcircle
% mu(~isnan(mu)) = mu(~isnan(mu))-pi/2;

% rescale angle so it runs from 0-2pi
mu(mu<0) = mu(mu<0) + (pi*2);
  
% rotate = 0;%1.5*pi;%1.75*pi;%3*pi/2;%pi;% 3*pi/2;
% mu = mu+rotate;
% mu = mod(mu,pi*2);

% mu(mu==0) = NaN;
% mu(mu==rotate) = NaN;
% mu(~isnan(mu)) = NaN;

end