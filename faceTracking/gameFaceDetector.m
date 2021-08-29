classdef gameFaceDetector < handle
    
    properties
        cam
        faceDetector
        pointTracker
        videoFrame
        frameSize
        videoPlayer
        bboxPoints
        bboxPolygon
        frameCount
        numPts
        bboxWidth
        refbbox
        oldPoints
        standStill
        rightTurn
        leftTurn
        jump
        squat
        turnBack
        samplingPeriod
    end
    
    methods
        function obj = gameFaceDetector           
            obj.faceDetector = vision.CascadeObjectDetector();
            obj.pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
            obj.cam = webcam();
            obj.videoFrame = snapshot(obj.cam); 
            obj.frameSize = size(obj.videoFrame);
            obj.videoPlayer = vision.VideoPlayer('Position', [100 100 [obj.frameSize(2), obj.frameSize(1)]+30]);
            obj.bboxPoints = zeros(4, 2);
            obj.bboxPolygon = zeros(1, 8);
            obj.refbbox = zeros(1, 8);
            obj.frameCount = 0;
            obj.numPts = 0;
            obj.bboxWidth = 0;
            obj.oldPoints = 0;
            obj.standStill = false;
            obj.rightTurn = false;
            obj.leftTurn = false;
            obj.jump = false;
            obj.squat = false;
            obj.samplingPeriod = 15;
      
        end
        
        function pos = getFacePos(obj)
            % Get the next frame.
            obj.videoFrame = snapshot(obj.cam);
            videoFrameGray = rgb2gray(obj.videoFrame);
            obj.frameCount = obj.frameCount + 1;

            if obj.numPts < 10
                % Detection mode.
                bbox = obj.faceDetector.step(videoFrameGray);

                if ~isempty(bbox)
                    % Find corner points inside the detected region.
                    points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox(1, :));

                    % Re-initialize the point tracker.
                    xyPoints = points.Location;
                    obj.numPts = size(xyPoints,1);
                    release(obj.pointTracker);
                    initialize(obj.pointTracker, xyPoints, videoFrameGray);
                    
                    % Save a copy of the points.
                    obj.oldPoints = xyPoints;
                    
                    % Convert the rectangle represented as [x, y, w, h] into an
                    % M-by-2 matrix of [x,y] coordinates of the four corners. This
                    % is needed to be able to transform the bounding box to display
                    % the orientation of the face.
                    obj.bboxPoints = bbox2points(bbox(1, :));

                    % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
                    % format required by insertShape.
                    obj.bboxPolygon = reshape(obj.bboxPoints', 1, []);

                    % Display a bounding box around the detected face.
                    obj.videoFrame = insertShape(obj.videoFrame, 'Polygon', obj.bboxPolygon, 'LineWidth', 3);

                    % Display detected corners.
                    obj.videoFrame = insertMarker(obj.videoFrame, xyPoints, '+', 'Color', 'white');

                obj.refbbox = obj.bboxPolygon; % reference face bbox
                obj.bboxWidth =  sqrt((obj.bboxPolygon(3)-obj.bboxPolygon(1)).^2+(obj.bboxPolygon(4)-obj.bboxPolygon(2)).^2);

                end
                
                disp('Detection mode')

            else
                % Tracking mode.
                [xyPoints, isFound] = step(obj.pointTracker, videoFrameGray);
                visiblePoints = xyPoints(isFound, :);
                oldInliers = obj.oldPoints(isFound, :);

                obj.numPts = size(visiblePoints, 1);

                if obj.numPts >= 10
                    % Estimate the geometric transformation between the old points
                    % and the new points.
                    [xform, inlierIdx] = estimateGeometricTransform2D(...
                        oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
                    visiblePoints = visiblePoints(inlierIdx, :);

                    % Apply the transformation to the bounding box.
                    obj.bboxPoints = transformPointsForward(xform, obj.bboxPoints);

                    % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
                    % format required by insertShape.
                    obj.bboxPolygon = reshape(obj.bboxPoints', 1, []);

                    % Tracking Changes
                    if mod(obj.frameCount,obj.samplingPeriod)==0

                        obj.standStill = false;
                        obj.rightTurn = false;
                        obj.leftTurn = false;
                        obj.jump = false;
                        obj.squat = false;

                        changebbox = obj.bboxPolygon - obj.refbbox;

                        % Pull points
                        d1 = changebbox(1:2);
                        d2 = changebbox(3:4);
                        d3 = changebbox(5:6);
                        d4 = changebbox(7:8);

                        % Threshold values
                        xThreshold = obj.bboxWidth * 0.8;
                        yThreshold = obj.bboxWidth * 0.6;

                        % Detect turns
                        if (d1(1) > xThreshold) && (d3(1) > xThreshold)
                            obj.leftTurn = true;
                            obj.turnBack = true;
                            disp('Left turn')
                        elseif (d1(1) < (-1 * xThreshold)) && (d3(1) < (-1 * xThreshold))
                            obj.rightTurn = true;
                            obj.turnBack = true;
                            disp('Right turn')
                        elseif (d1(2) > yThreshold) && (d3(2) > yThreshold)
                            obj.jump = true;
                            obj.turnBack = true;
                            disp('Jump')
                        elseif (d1(2) < (-1 * yThreshold)) && (d3(2) < (-1 * yThreshold))
                            obj.jump = true;
                            obj.turnBack = true;
                            disp('Squat')                
                        end

%                         disp("D1: ");
%                         disp(d1(1));
%                         disp("D2: ");
%                         disp(d2(1));
%                         disp("D3: ");
%                         disp(d3(1));
%                         disp("D4: ");
%                         disp(d4(1));
%                        disp("------------------");

                    end

                    % Display a bounding box around the face being tracked.
                    obj.videoFrame = insertShape(obj.videoFrame, 'Polygon', obj.bboxPolygon, 'LineWidth', 3);

                    % Display tracked points.
                    obj.videoFrame = insertMarker(obj.videoFrame, visiblePoints, '+', 'Color', 'white');

                    % Reset the points.
                    obj.oldPoints = visiblePoints;
                    setPoints(obj.pointTracker, obj.oldPoints);

                    if obj.turnBack == true
                        % Pause
                        pause(0.4);
                        obj.turnBack = false;
                    end


                end

            end

            % Display the annotated video frame using the video player object.
            step(obj.videoPlayer, obj.videoFrame);
            
            pos = obj.bboxPolygon;

        end
        
        function delete(obj)
            delete(obj.cam);
            release(obj.videoPlayer);
            release(obj.pointTracker);
            release(obj.faceDetector);

        end
        
    end
end

