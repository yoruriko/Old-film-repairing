function [ frames ] = correct_strip( frames,filter_range,threshold)
frames=double(frames);
 
for i= 1:size(frames,3)
    raw_frame = frames(:,:,i);
    last_fill=raw_frame;
    fillter_frame = raw_frame;
    result_frame = raw_frame;
    
    % By iterating the kernel size from large to small, we can extract the
    % vertical artefacts at differnet frequency and progressively add the 
    % edges back into the result image, hence minimise the blur.
    for k = filter_range
        
        % Apply median filtering to each row in the image with different
        % kernel size to compute the filtered image.
        for j = 1:size(raw_frame,1)
            raw = raw_frame(j,:);
            fill = medfilt1(raw,k);    
            fillter_frame(j,:) = fill;
        end
        
        % Get the absolute difference between current fillter level with
        % the last level, use a thereshold to capture the vertical
        % artefacts. This allow us to detect vertical artefacts with
        % different frequency.
        diff=abs(last_fill-fillter_frame);
        last_fill=fillter_frame;
        map = diff>threshold;
        
        % Replace the artefacts with the filltered pixel
        result_frame(map)=fillter_frame(map);
     
    end
    
    frames(:,:,i)=result_frame;
end

end

