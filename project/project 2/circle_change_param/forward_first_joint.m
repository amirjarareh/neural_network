function q = forward_first_joint(theta)
    l1 = 1.2;
    l2 = 0.8;
    m1 = 6;
    m2 = 4;
    g = 9.81;

    xp = l1*cos(theta(1)); 
    yp = l1*sin(theta(1));

    q = [xp yp]';
end