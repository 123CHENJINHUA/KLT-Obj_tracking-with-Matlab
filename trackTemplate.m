function [new_window] = trackTemplate(img1, img2, window, sigma)

img1_gray=img1;
img2_gray=img2;
[row1, col1] = size(img1_gray);
% smooth use gaussian kernel --sigma
gaussFilt = fspecial('gaussian',10,sigma);  % SEE 'help fspecial' 
img1_gray = imfilter(img1_gray, gaussFilt, 'symmetric');
img2_gray = imfilter(img2_gray, gaussFilt, 'symmetric');
img1_gray = im2double(img1_gray);
img2_gray = im2double(img2_gray);

if window==[0,9,9,0]
    I_NCC=normxcorr2(img1_gray,img2_gray);
    [ypeak,xpeak]=find(I_NCC==max(I_NCC(:))); % bottom right pt: y2, x2
    new_window = [xpeak-col1+1,ypeak-row1+1,xpeak,ypeak];
else    
p = [0; 0];
step = 0;
threshold = 0.01;
max_iteration = 100;

[Tx, Ty] = meshgrid((1:col1)+window(1)-1, (1:row1)+window(2)-1);
[Gx, Gy] = imgradientxy(img1_gray, 'central');
Ix = Gx(:);
Iy = Gy(:);
A = [Ix, Iy];
for i=1:max_iteration
    % 1. Warp I with W
    warped = interp2(img2_gray, Tx + p(1), Ty + p(2), 'Bilinear');
    warped(isnan(warped)) = 0;
    % 2. Subtract I from T
    I_error = img1_gray(:) - warped(:);
    % 3. Multiply steepest descend with error and 8. compute dp
    dp =  pinv(A) * I_error;
    % 4. Update the parameters p <- p + delta_p
    p = p + dp;
    if norm(dp) < threshold
        break;
    end
    step = step + 1;
end
new_window = window + [p(1), p(2), p(1), p(2)];
end
end
