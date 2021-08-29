% Create the face detector object.
faceDetector = vision.CascadeObjectDetector();

% Create the point tracker object.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% Create the webcam object.
cam = webcam();

% Capture one frame to get its size.
videoFrame = snapshot(cam);
frameSize = size(videoFrame);

% Create the video player object.
videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);

% Method
% getFacePosition

% State of Class
% in loop 

% Destructor
% clear cam

runLoop = true;
numPts = 0;
frameCount = 0;
prevbbox = zeros(1,8);
samplingRate = 15;
bboxWidth = 0;
turnBack = false;


while runLoop && frameCount < 300
    

    
    % Get the next frame.
    videoFrame = snapshot(cam);
    videoFrameGray = rgb2gray(videoFrame);
    frameCount = frameCount + 1;

    if numPts < 10
        % Detection mode.
        bbox = faceDetector.step(videoFrameGray);

        if ~isempty(bbox)
            % Find corner points inside the detected region.
            points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox(1, :));

            % Re-initialize the point tracker.
            xyPoints = points.Location;
            numPts = size(xyPoints,1);
            release(pointTracker);
            initialize(pointTracker, xyPoints, videoFrameGray);

            % Save a copy of the points.
            oldPoints = xyPoints;

            % Convert the rectangle represented as [x, y, w, h] into an
            % M-by-2 matrix of [x,y] coordinates of the four corners. This
            % is needed to be able to transform the bounding box to display
            % the orientation of the face.
            bboxPoints = bbox2points(bbox(1, :));

            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            bboxPolygon = reshape(bboxPoints', 1, []);

            % Display a bounding box around the detected face.
            videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);

            % Display detected corners.
            videoFrame = insertMarker(videoFrame, xyPoints, '+', 'Color', 'white');
        
        refbbox = bboxPolygon; % reference face bbox
        prevbbox = bboxPolygon;
        bboxWidth =  sqrt((bboxPolygon(3)-bboxPolygon(1)).^2+(bboxPolygon(4)-bboxPolygon(2)).^2);
        
        end
        
    else
        % Tracking mode.
        [xyPoints, isFound] = step(pointTracker, videoFrameGray);
        visiblePoints = xyPoints(isFound, :);
        oldInliers = oldPoints(isFound, :);

        numPts = size(visiblePoints, 1);

        if numPts >= 10
            % Estimate the geometric transformation between the old points
            % and the new points.
            [xform, inlierIdx] = estimateGeometricTransform2D(...
                oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
            oldInliers    = oldInliers(inlierIdx, :);
            visiblePoints = visiblePoints(inlierIdx, :);

            % Apply the transformation to the bounding box.
            bboxPoints = transformPointsForward(xform, bboxPoints);

            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            bboxPolygon = reshape(bboxPoints', 1, []);

            % Tracking Changes
            if mod(frameCount,samplingRate)==0
                
                standStill = false;
                rightTurn = false;
                leftTurn = false;
                jump = false;
                squat = false;
                
                changebbox = bboxPolygon - refbbox;
                prevbbox = bboxPolygon;

                % Pull points
                d1 = changebbox(1:2);
                d2 = changebbox(3:4);
                d3 = changebbox(5:6);
                d4 = changebbox(7:8);

                % Threshold values
                xThreshold = bboxWidth * 0.70;
                yThreshold = bboxWidth * 1.0;
        
                % Detect turns
                if (d1(1) > xThreshold) && (d3(1) > xThreshold)
                    leftTurn = true;
                    turnBack = true;
                    disp('Left turn')
                elseif (d1(1) < (-1 * xThreshold)) && (d3(1) < (-1 * xThreshold))
                    rightTurn = true;
                    turnBack = true;
                    disp('Right turn')
                elseif (d1(2) > yThreshold) && (d3(2) > yThreshold)
                    jump = true;
                    turnBack = true;
                    disp('Jump')
                elseif (d1(2) < (-1 * yThreshold)) && (d3(2) < (-1 * yThreshold))
                    jump = true;
                    turnBack = true;
                    disp('Squat')                
                end

                disp("D1: ");
                disp(d1(1));
                disp("D2: ");
                disp(d2(1));
                disp("D3: ");
                disp(d3(1));
                disp("D4: ");
                disp(d4(1));
                disp("---------");


                %
                %                disp(frameCount)
                %                disp(changebbox)
            end

            % Display a bounding box around the face being tracked.
            videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);

            % Display tracked points.
            videoFrame = insertMarker(videoFrame, visiblePoints, '+', 'Color', 'white');

            % Reset the points.
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);
            
            
            % Insert code from others
            
            
            if turnBack == true
                % Pause for 1 second
                pause(0.5);
                turnBack = false;
            end
            
            
        end

    end

    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);

    % Check whether the video player window has been closed.
    runLoop = isOpen(videoPlayer);
end

% Clean up.
clear cam;
release(videoPlayer);
release(pointTracker);
release(faceDetector);


