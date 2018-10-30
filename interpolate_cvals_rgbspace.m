function[irgbs] = interpolate_cvals_rgbspace(rgbs)

%give pair of rgb values, this funciton will interpolate between them

n = 100; % number of values between 2 colors

rgbshape = size(rgbs);
n_colors = rgbshape(1);

irgbs = zeros((n_colors-1)*n,3);

for c = 1:(n_colors-1)
    irgbs(((c-1)*n)+1:(c*n),1) = linspace(rgbs(c,1),rgbs(c+1,1),n);
    irgbs(((c-1)*n)+1:(c*n),2) = linspace(rgbs(c,2),rgbs(c+1,2),n);
    irgbs(((c-1)*n)+1:(c*n),3) = linspace(rgbs(c,3),rgbs(c+1,3),n); 
end
