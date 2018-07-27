function [ result ] = remove_camera_shake( frames,threshold,max_dX,max_dY)
frames = double(frames);
% initalise the result frames
result = frames;
total_frames = size(frames,3);

% horizontal sobel kernel for edge detection
sobel_kernel = [1,2,1;0,0,0;-1,-2,-1];

% compute the map for the first frame, used as the reference for
% fllowing frame
last_map = compute_map(frames(1:end/2,:,1),sobel_kernel,threshold);

for i =2:total_frames
    
    last_frame = frames(:,:,i-1);
    current_frame = frames(:,:,i);
    
    % compute the map of current frame
    current_map = compute_map(current_frame(1:end/2,:),sobel_kernel,threshold);
    
    % apply cross correlation to estimate the translation bewtween last
    % frame and current frame
    offset = compute_translation(last_map,current_map,max_dX,max_dY);
    
    % if the total translation is 0, then keep the original frame,
    % otherwise wrap empty space created by translation
    if sum(abs(offset))>0
        result_frame = wrap_frame(last_frame,current_frame,offset);
    else
        result_frame = current_frame;
    end
    
    result(:,:,i) = result_frame;
    
    % update the last map for reference of next frame
    last_map = compute_map(result_frame(1:end/2,:),sobel_kernel,threshold);
end

result=uint8(result);

%% ========================================================================
function result_frame = wrap_frame(ref,img,offset)
    % uses the average image of reference and target frame for wraping
    average_img = (ref+img)/2;
    % label the empty space created by translation as -1
    trans_img = imtranslate(img , offset,'FillValues',-1);
    % fill the empty pixels with pixels from average image 
    trans_img(trans_img==-1) = average_img(trans_img==-1);
    
    result_frame = trans_img;
end
%% ========================================================================
function offset = compute_translation(m1,m2,max_dX,max_dY)
    m1 = double(m1);
    m2 = double(m2);
    
    % compute the cross correlation of two frames
    crr = xcorr2(m1,m2);
    % uses the largest respond value as the estimate translation
    [~,ind]=max(abs(crr(:)));
    % covert the index back to subscript
    [ypeak,xpeak] = ind2sub(size(crr),ind);
    
    % compute the offset of peak response
    offset_x = (xpeak-size(m1,2));
    offset_y = (ypeak-size(m1,1));
    
    % if the translation is larger than the maxium translation we defined
    % then set the translation to 0.
    if offset_x < -max_dX
        offset_x = 0;
    elseif offset_x >max_dX
        offset_x = 0;
    end
    
    if offset_y < -max_dY
        offset_y = 0;
    elseif offset_y >max_dY
        offset_y = 0;
    end
    
    offset=[offset_x offset_y];
end

%% ========================================================================
function map = compute_map(frame,kernel,threshold)
    % apply horizontal sobel kernel to compute the manitude of the gradient
    gy = imfilter(frame,kernel,'replicate');
    gx = imfilter(frame,kernel','replicate');
    G = sqrt(gy.^2+gx.^2);
    % kept the response that is larger than the given thereshold
    map = G>threshold;
end


end

