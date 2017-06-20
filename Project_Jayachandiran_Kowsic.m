function Project_Jayachandiran_Kowsic()
    % Clear the console
    % Clear the workspace
    % Close all open MATLAB windows
    clc;
    clear;
    close all;
    
    % Read in the image
    im = imread('Sample1.jpg');
    
    % We will be converting the image to grayscale because there will be a
    % good contrast between the background and the coins.
    % Follow it by converting it to double for easier manipulation
    im_gray = im2double(rgb2gray(im));
    
    % Use histogram to find the threshold value approximately so that it
    % will be easier to distinguish the coins in the foreground from the 
    % background.
    
    % imhist(im_gray);
    % title('Histogram of original image', 'FontSize', 14);
    
    % The threshold value was calculated from the histogram. This is an
    % approximate value. This value will be in the range 0 to 1.
    thresholdValue = 0.2;
    
    % Convert the image to black and white so that each pixel in the image
    % could belong to only one of the two classes - background or the
    % foreground coin.
    binaryImage = imbinarize(im_gray, thresholdValue);
    
    % We know that the connected components in the image (the coins) occupy
    % more than 500 pixels. We use this information to remove any noise in
    % the image whose connected components have fewer than 500 pixels.
    binaryImageRemovedNoise = bwareaopen(binaryImage, 500);
    
    % Remove any object in the image(coins) that touch the border of the
    % image
    cleanBinaryImage = imclearborder(binaryImageRemovedNoise);
    
    % Fill in the holes in the binary image
    cleanBinaryImage = imfill(cleanBinaryImage, 'holes'); 
    
    % Tried using open and close morphological effects to smooth the circle
    % circumference but did not work
    % out = imopen(out, strel('disk', 100));
    % out = imclose(out, strel('disk', 100));

    % Use Hough transform to find the circles in the image.
    
    % The minimum radius for the imfindcircles function is calculated using
    % imdistline tool available in matlab.
    
    % lineTool = imdistline;
    % delete lineTool
    
    % Use imfindcircles to find the circles in the image using Hough
    % Transform. The parameters for the function depend on the coins in
    % that particular image. This will vary depending on the distance of
    % the camera lens from the coins.
    % Here we are trying to find circles in the radius range of 200 to 1000
    % pixels. Since in a black and white image, the circles will all be
    % white in color, we set the ObjectPolarity parameter to bright.
    % Sensitivity tells which circles to identify. The values are in the 
    % range 0 and 1 - values closer to 0 find very small circles which may
    % consider even noise as circles and values closer to 1 identify large
    % circles.
    [~, radii, ~] = imfindcircles(cleanBinaryImage, [200, 1000], ...
        'ObjectPolarity','bright', 'Sensitivity', .97);

    % Initialize the denomination counts to 0s
    quarterCount = 0;
    nickelCount = 0;
    dimeCount = 0;
    pennyCount = 0;
    
    % Get the lowest radius.
    % Since there should be at least one dime in the image, this smallest
    % radius should belong to that of a dime. 
    % This dime will then be used as reference.
    minRadius = min(radii);
    
    % Use the radii of the so found circles to determine the coin
    % denominations.
    % Check the value of str returned by the ClassifyCoins function and
    % increment the count of the respective denominations.
    for circleIdentifier = 1: numel(radii)
        coinName = ClassifyCoinsRatio(radii(circleIdentifier), minRadius);
        
        if(strcmpi(coinName, 'Quarter'))
            quarterCount = quarterCount + 1;
        else
            if(strcmpi(coinName, 'Nickel'))
                nickelCount = nickelCount + 1;
            else
                if(strcmpi(coinName, 'Dime'))
                    dimeCount = dimeCount + 1;
                else
                    pennyCount = pennyCount + 1;
                end
            end
        end
    end
    
    % Display the counts of the coins
    fprintf('Quarters : %d\n', quarterCount);
    fprintf('Nickels  : %d\n', nickelCount);
    fprintf('Dimes    : %d\n', dimeCount);
    fprintf('Pennies  : %d\n\n', pennyCount);
    
    % Display the total value of the coins
    totalVal = (0.25 * quarterCount) + (0.10 * dimeCount) + ...
                (0.05 * nickelCount) + (0.01 * pennyCount);
    
    fprintf('Total value of coins in the image : $%.2f\n', totalVal);
end

function coin = ClassifyCoinsRatio(currentRadius, minRadius)
    % This function classifies the coins by calculating the ratio of the
    % radius of the coin to the lowest radius. This ratio will give an idea
    % as to how big the coin is compared to a dime.
    % The function returns the name of coin so classified.
    if((currentRadius / minRadius) > 1.4)
        coin = 'Quarter';
    else
        if((currentRadius / minRadius) >= 1.18)
            coin = 'Nickel';
        else
            if((currentRadius / minRadius) >= 1.1)
                coin = 'Penny';
            else
                coin = 'Dime';
            end
        end
    end
end