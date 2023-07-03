function [H,P] = encodeStateHV_delta(delta, H, P1, P2, P3, P4, maxVal, minVal)
% Takes in the continuous four element state vector 
% of the system and encodes this into the state hypervector. 
% 1) Find the difference from previous continuous state
% 2) Bind this difference to the previous feature vectors
% 3) Bind new feature vectors to the current state hypervector
%
% INPUT
%   prevState: previous continuous state
%   state: continuous state [x, x_dot, theta, theta_dot]
%   H: continuous state hypervector
%   P1-P4: feature hypervectors
%
% OUTPUT
%   H: new continuous state hypervector

% Find delta with previous state
%delta = state - prevState;   

% Find mapping range
limit = maxVal - minVal; % DEBUG

% Linearly map delta to between 0:2*pi around the unit circle.
% I dont think this mapping to 2*pi matters, because the only thing that
% matters is the gradient descent of the model HV. 
%map = (delta./limit) * 2 * pi; % DEBUG
map = delta;

% Encode feature hypervectors. The PhasorHV class is a child handle,
% therefor the changes will persist across functions.
encP1 = P1.encode(map(1));                
encP2 = P2.encode(map(2));
encP3 = P3.encode(map(3));
encP4 = P4.encode(map(4));
P = [encP1,encP2,encP3,encP4];

% Bind new feature hypervectors to the old state 
% hypervector to make the new state hypervector
H = bind(H,encP1);
H = bind(H,encP2);
H = bind(H,encP3);
H = bind(H,encP4);

%H = superimpose(encP1,encP2,encP3,encP4);
end

