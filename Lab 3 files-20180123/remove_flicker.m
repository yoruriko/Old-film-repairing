function [frames] = remove_flicker( frames,window_size )
    frames=double(frames);
    total_frames = size(frames,3);
    
    r = floor(window_size/2);
    
    for k=r+1:total_frames-r
        
        % compute averaege intenesity of each pixel
        if k<r+1
            average_frame = uint8(sum(frames(:,:,1:window_size),3)/window_size);
        elseif k>total_frames-r
            average_frame = uint8(sum(frames(:,:,total_frames-window_size:end),3)/window_size);
        else
            average_frame = uint8(sum(frames(:,:,k-r:k+r),3)/window_size);
        end
        current_frame = uint8(frames(:,:,k));
        
        % put each intentsity level into individual bin 
        hist_mean = imhist(average_frame);
        hist_current=imhist(current_frame);
        
        % My own implement of computing the histogram, but slower than
        % imhist.
        %hist_mean = compute_hist(average_frame);
        %hist_current=compute_hist(current_frame);
        
        % normalise the cumulative distribution of the histogram
        cdf_mean = cumsum(hist_mean)/sum(hist_mean(:));
        cdf_current = cumsum(hist_current)/sum(hist_current(:));

        % compute the mapping of current histagram with the avereage histagram
        % , map each intensity level with the  first bin that has higher value
        % than it in the average bins.
        map = zeros(256,1);
        for i = 1:256
            for j = 0:255
                val = 256 - j;
                if cdf_current(i) >= cdf_mean(val)
                    map(i) = val - 1;
                    break;
                end
            end
        end
        
        % Adjust current frame by assign all pixels with given intensity 
        % level in the raw image with a new intensity in the mapping.
        result_frame = current_frame;
        for i = 1:256
            result_frame(current_frame==i)=map(i);
        end
        
        frames(:,:,k) = uint8(result_frame);
        %result_frame = imhistmatch(uint8(current_frame),average_frame,256);
    end

end

% compute the histagram of the frame (I used imhist to obtained the histogram
% , this is my own implementation but slower)
function hist = compute_hist(frame)
    hist = zeros(1,256);
    for k=1:256
        val = k-1;
        count = frame(frame==val);
        hist(k)=count;
    end
end