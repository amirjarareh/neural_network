function [q,qdot] = forward_kinematics(theta,theta_dot,sample_time)
    l1 = 1.2;
    l2 = 0.8;
    m1 = 6;
    m2 = 4;
    g = 9.81;

    xp = l1*cos(theta(1)) + l2*cos(theta(1)+theta(2));
    yp = l1*sin(theta(1)) + l2*sin(theta(1)+theta(2));

    xp_dot = -l1*theta_dot(1)*sin(theta(1))- l2*(theta_dot(1)+theta_dot(2))*sin(theta(1)+theta(2));
    yp_dot = l1*theta_dot(1)*cos(theta(1)) + l2*(theta_dot(1)+theta_dot(2))*cos(theta(1)+theta(2));
    
    % theta_next = theta + sample_time*theta_dot;
    % xp_next = l1*cos(theta_next(1)) + l2*cos(theta_next(1)+theta_next(2));
    % yp_next = l1*sin(theta_next(1)) + l2*sin(theta_next(1)+theta_next(2));
    % qdot = ([xp_next yp_next]' - [xp yp]')/sample_time;

    q = [xp yp]';
    qdot = [xp_dot yp_dot]';
    
end