function [cuts] = detect_cuts(frames,threshold)
    frames=double(frames);
    total_frames = size(frames,3);
    
    cutIndex = 1;
    lastCut = 1;
    
    for frame_index=2:total_frames
        
        current_frame = frames(:,:,frame_index);
        last_frame = frames(:,:,frame_index-1);
        diff_frame = abs((current_frame-last_frame));
        
        % If the absolute difference between two frame is larger than the given
        % threshold, then mark current frame as the begining of next cut.
        if( sum(diff_frame(:)) > sum(current_frame(:))*threshold)
            
            cuts{cutIndex}=uint8(frames(:,:,lastCut:frame_index-1));
            
            cutIndex=cutIndex+1;
            lastCut = frame_index;
            
        end
    end
    
    cuts{cutIndex}=uint8(frames(:,:,lastCut:end));
    
end

