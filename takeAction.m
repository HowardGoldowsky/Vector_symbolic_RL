function  [newState, done] = takeAction(action, state)

% Physics model

GRAVITY = 9.8;
MASSCART = 1.0;
MASSPOLE  = 0.1;
TOTAL_MASS = (MASSPOLE + MASSCART);
LENGTH = 0.5;                                                       % half the pole's length
POLEMASS_LENGTH = (MASSPOLE * LENGTH);
FORCE_MAG = 10.0;
TAU = 0.02;                                                           % seconds between state updates

x = state(1);
x_dot = state(2);
theta = state(3);
theta_dot = state(4);

if (action == 2)
    force = FORCE_MAG;
else
    force = -FORCE_MAG;
end

costheta = cos(theta);
sintheta = sin(theta);

temp = (force + POLEMASS_LENGTH * theta_dot * theta_dot * sintheta) / TOTAL_MASS;

thetaacc = (GRAVITY * sintheta - costheta* temp) / (LENGTH * ((4/3) - MASSPOLE * costheta * costheta / TOTAL_MASS));
xacc  = temp - POLEMASS_LENGTH * thetaacc* costheta / TOTAL_MASS;

% Update the four state variables, using Euler's method.

x  = x + TAU * x_dot;
x_dot = x_dot + TAU * xacc;
theta = theta + TAU * theta_dot;
theta_dot = theta_dot + TAU * thetaacc;

newState(1) = x;
newState(2) = x_dot;
newState(3) = theta;
newState(4) = theta_dot;

done = fail(newState);

end % function
