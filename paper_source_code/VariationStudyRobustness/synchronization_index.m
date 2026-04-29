function S = synchronization_index(theta1, theta2)
% Compute synchronization index from relative phase.
% The paper describes the synchronization index as based on the variance
% of relative phase, ranging from 0 to 1.

    phi = angle(exp(1i*(theta1 - theta2)));

    R = abs(mean(exp(1i*phi)));

    S = R;
end