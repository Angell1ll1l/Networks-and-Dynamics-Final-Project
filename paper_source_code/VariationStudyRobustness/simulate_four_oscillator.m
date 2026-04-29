function [t, theta] = simulate_four_oscillator(params, T, dt, omega_mean, omega_sd, beta)
% Simulate the four-oscillator Kuramoto-type model.
%
% params = [i1, e1, i2, e2]
% Oscillator numbering:
% 1 = person 1 perception
% 2 = person 1 action
% 3 = person 2 action
% 4 = person 2 perception

    i1 = params(1);
    e1 = params(2);
    i2 = params(3);
    e2 = params(4);

    K = [0  i1 e1 0;
     i1 0  0  0;
     0  0  0  i2;
     0  e2 i2 0];


    t = (0:dt:T)';
    nSteps = length(t);

    theta = zeros(nSteps, 4);

    % random initial phases
    theta(1,:) = 2*pi*rand(1,4);

    % intrinsic frequencies in cycles per second converted to rad/s
    omega_hz = omega_mean + omega_sd*randn(1,4);
    omega = 2*pi*omega_hz;

    % Euler-Maruyama integration
    for k = 1:nSteps-1
        coupling = zeros(1,4);

        for n = 1:4
            for p = 1:4
                coupling(n) = coupling(n) + K(n,p)*sin(theta(k,p) - theta(k,n));
            end
        end

        % noise term. Scaling by sqrt(dt) follows Euler-Maruyama convention.
        noise = beta * randn(1,4) / sqrt(dt);

        dtheta = omega + coupling + noise;

        theta(k+1,:) = theta(k,:) + dt*dtheta;
    end
end