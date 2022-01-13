function best = cylfit_ransac_fast(xyz, outRatio, normPts)
% CYLFIT_RANSAC_FAST Utilize RANSAC to fit cylinder to a set of 3D points.
%   
%       Call: best = cylfit_ransac(xyz, outRatio, normPts)
%   
%        xyz: N x 3 matrix of x,y,z coordinates of points
%   outRatio: percentage of points to be considered outliers [0.00-1.00)
%    normPts: number of points to use to estimate point cloud normals
%       best: 1 x 9 matrix of estimation of center (1 x 3), orientation of
%             cylinder axis (1 x 3), diameter (scalar), uncertainty of
%             radius (scalar), and convergence of solution (boolean)
% 
%   Uses elements of "Least Squares Geometric Element Software" by Ian
%   Smith, National Physical Laboratory, England (ian.smith@npl.co.uk). 
%
%   See also: pcnormals, lscylinder.

% calculate number of trials, number of pts to keep
num_trials = calc_min_trials(0.999, outRatio, 2);
num_trials = num_trials*3;
N = size(xyz,1);
keep = ceil((1 - outRatio)*N); % number of points to keep

% initialize variable to store parameters of initial fit cylinder
% row = 7 cylinder params + RMSE: [nx,ny,nz,x,y,z,radius,rmse_v]
initial_fit = zeros(num_trials,8);

% store points as a point cloud object, estimate normals
ptCloud = pointCloud(xyz);
normals = pcnormals(ptCloud,normPts);

% RANSAC trials for initial fit cylinder
for ii = 1:num_trials
    angle = 0;   % initial value for while loop below
    n = [0 0 0]; % initial value for while loop below
    % Values 30° and 150° chosen arbitrarily to ensure strong solution for
    %    orientation and center of initial cylinder.
    % Value of z-component of cylinder axis chosen to ensure that cylinder
    %    is upright.
    while (angle < 30 || angle > 150) || (abs(n(3)) < 0.98)
        % choose initial random points and associated normals
        i = randi(ptCloud.Count);
        j = i;
        while j == i
            j = randi(ptCloud.Count);
        end

        p = xyz(i,:); q = xyz(j,:);
        np = normals(i,:); nq = normals(j,:);
        
        % find orientation and center of initial cylinder
        n = cross(np,nq)./norm(cross(np,nq));
        initial_fit(ii,1:3) = n;

        r = p - dot(p,n)*n; s = q - dot(q,n)*n;
        nr = np - dot(np,n)*n; ns = nq - dot(nq,n)*n;
        
        % recalc angle btw projected normals
        angle = mod(acosd(dot(nr,ns)),180);
    end
    
    % L1 = r + t * nr
    % L2 = s + u * ns
    % t * nr = (s - r) + u * ns
    % t * (nr x ns) = (s - r) x ns
    t = cross(s-r,ns)/cross(nr,ns);
    
    % plug value t back into equation of line L1 to find intersection
    % intersection of two projected lines c, which lies on axis of cylinder
    c = r + t*nr;
    initial_fit(ii,4:6) = c;
    
    % estimation of radius of cylinder is distance from point r to point c
    radius = sqrt((c(1)-r(1))^2 + (c(2)-r(2))^2 + (c(3)-r(3))^2);
    initial_fit(ii,7) = radius;
    
    % residuals and RMSE
    v = cyl_residuals(xyz,n,c,radius);
    rmse_v = sqrt(sum(v));
    initial_fit(ii,8) = rmse_v;
end

% sort initial fit cylinders, keep best
for jj = 1:num_trials % sort out 0 and NaN residuals
    if initial_fit(jj,8) == 0 || isnan(initial_fit(jj,8))
        initial_fit(jj,8) = Inf; % arbitrary high value for sorting
    end
end

sort_initial_fit = sortrows(initial_fit,8);
% keep best initial fit with proper orientation
best_initial_fit = sort_initial_fit(1,:);

n = best_initial_fit(1:3) % normal
c = best_initial_fit(4:6) % center
r = best_initial_fit(7)   % radius

% recalculate residuals
v = cyl_residuals(xyz,n,c,r);

% sort points by residuals, keep inliers
sortXYZ = sortrows([xyz v],4);
inliers = sortXYZ(1:keep,1:3); % (1 - outRatio) percent of points kept
    
% least squares fit of cylinder to inliers
if length(inliers) > 20
    [x0n, an, rn, d, sigmah, conv, Vx0n, Van, urn, GNlog, ... 
    a, R0, R] = lscylinder(inliers, c', n', r, 1, 1); %#ok<*ASGLU>
    best = [x0n;an;rn*2;urn;conv]'; % LOOK HERE: outputs diameter!
else
    fprintf('not enough points!\n')
    best = zeros(1,9);
end

% % plot final cylinder
% top and bottom points of axis of plotted cylinder
len = 1/2; % height of slice divided by 2
top = best(1:3) + len*best(4:6);
bot = best(1:3) - len*best(4:6);
rad = best(7)/2; % need radius

params = [top bot rad];
model = cylinderModel(params);

figure
hold off
plot(model)
hold on
plot3(xyz(:,1),xyz(:,2),xyz(:,3),'r.')
xlabel x,ylabel y,zlabel z
axis equal

fprintf(' - RANSAC trials: %d\n',num_trials)
end


function v = cyl_residuals(xyzPts,normal,center,rad)
% CYL_RESIDUALS Calculate the residuals of a set of 3D points from a
%    cylinder.
%   
%       Call: v = cyl_residuals(xyzPts,normal,center,rad)
%             
%     xyzPts: N x 3 matrix of x,y,z coordinates of points
%     normal: orientation of cylinder axis (1 x 3 vector)
%     center: point on axis of vector (1 x 3)
%        rad: radius of cylinder (scalar)
%          v: absolute value of the orthogonal distance of each point from 
%             the cylinder surface (N x 1)

N = size(xyzPts,1);

% calculate distance of each point xyz from central axis
% if X is a point in space and L is the line r(t) = c + t * n, then
%      d(X,L) = |Xc x n| / |n|
% where, in this case, |n| = 1
d = zeros(N,1);
Xc = [xyzPts(:,1)-center(1) xyzPts(:,2)-center(2) xyzPts(:,3)-center(3)];
for jj = 1:size(d,1)
    d(jj) = norm(cross(Xc(jj,:),normal));
end

% calculate residuals of initial cylinder
v = abs(d - rad);
end    


function num_trials = calc_min_trials(P_min, max_err, U)
%   calculates the minimum number of ransac trials from manual of
%   photogrammetry 5 ed. p 156
%   P_min is the probability a correct solution will be found
%   max_err is the ratio of allowable outliers, e.g. 0.5 if up to 50%
%   of points may be outliers, e.g. 0.95 for 95% confidence
%   U is the number of unknowns

num_trials = ceil((log(1-P_min))/(log(1-(1-max_err)^U)));
end