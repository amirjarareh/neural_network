function [ z ] = phi( x )
z1=(1-exp(-0.05*x));
z2=(1+exp(-0.05*x));
z=z1./z2;
end

