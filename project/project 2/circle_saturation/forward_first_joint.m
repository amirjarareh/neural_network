function q = forward_first_joint(theta)
    l1 = 0.6;
    l2 = 0.4;
    m1 = 3;
    m2 = 2;
    g = 9.81;

    xp = l1*cos(theta(1)); 
    yp = l1*sin(theta(1));

    q = [xp yp]';
end