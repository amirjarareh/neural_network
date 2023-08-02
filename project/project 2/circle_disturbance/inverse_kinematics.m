function [theta,theta_dot] = inverse_kinematics(q,qdot,sample_time)
%     theta = q;
%     theta_dot = qdot;

    l1 = 0.6;
    l2 = 0.4;
    m1 = 3;
    m2 = 2;
    g = 9.81;
    
    
    t2 = acos((q(1)^2 + q(2)^2 -l1^2-l2^2)/(2*l1*l2));
    t1 = atan(q(2)/q(1)) - atan((l2*sin(t2))/(l1+l2*cos(t2)));
    
    q_next = q + sample_time*qdot;
    t4 = acos((q_next(1)^2 + q_next(2)^2 -l1^2-l2^2)/(2*l1*l2));
    t3 = atan(q_next(2)/q_next(1)) - atan((l2*sin(t4))/(l1+l2*cos(t4)));
    
    theta = [t1 t2]';
    theta_dot = ([t3 t4]' - [t1 t2]')/sample_time;
end