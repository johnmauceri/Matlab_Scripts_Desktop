function wedges = find_wedges(filenameCC,filenameMLO,Direction,xref,yref)
    %Direction = 1: MLO --> CC
    %Direction = 0: CC  --> MLO
 
    [lin, err] = CCMLO_wedge(filenameCC, filenameMLO, Direction, xref, yref);

    %Min wedge line
    x(1) = lin(3,1);
    y(1) = lin(3,2);
    x(2) = lin(4,1);
    y(2) = lin(4,2);
    y1_l = y(1);
    y2_l = y(2);
    x1_l = x(1);
    x2_l = x(2);
    m_l  = (y2_l - y1_l) / (x2_l - x1_l);

    %Max wedge line
    x(1) = lin(5,1);
    y(1) = lin(5,2);
    x(2) = lin(6,1);
    y(2) = lin(6,2);
    y1_u = y(1);
    y2_u = y(2);
    x1_u = x(1);
    x2_u = x(2);
    m_u  = (y2_u - y1_u) / (x2_u - x1_u);

    %Compute intersection between max and min wedge lines
    x_common = (y1_l - y1_u + m_u*x1_u - m_l*x1_l)/ (m_u - m_l);
    y_common = m_u*(x_common - x1_u) + y1_u;

    wedges = struct([]);
    wedges(1).x = [x1_u x1_l x_common];
    wedges(1).y = [y1_u y1_l y_common];
    wedges(2).x = [x2_u x2_l x_common];
    wedges(2).y = [y2_u y2_l y_common];
end
