
function X = triang(m1,m2,P1,P2)

% triangulate x1 and x2 using cameras P1 and P2
A = [m1(1)*P1(3,:)-P1(1,:);...
    m1(2)*P1(3,:)-P1(2,:);...
    m2(1)*P2(3,:)-P2(1,:);...
    m2(2)*P2(3,:)-P2(2,:)];

[u s v] = svd(A);
X = v(:,end);
X = X(1:3)/X(4);

end