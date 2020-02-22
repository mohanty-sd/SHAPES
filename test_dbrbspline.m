%% Generate Fig.1 of the SHAPES paper
%Predictor values
x = 0:0.001:1;
%Breakpoints
b = [0,       0.35,     0.5,    0.7,    0.75,   0.8,      1];
%Multiplicities of breakpoints
m = [3,        0         2,      0,      1,      0,        3];

disp(['Number of knots = ', num2str(length(b)+sum(m))]);

bsplMat = dbrbspline(x,b,4,m);

[nBspl,nSmpl] = size(bsplMat);

figure;
hold on;
for lpb = 1:nBspl
    pltStyl = mod(lpb,2);
    switch pltStyl
        case 0
            plot(x,bsplMat(lpb,:),'Color',160*ones(1,3)/255);
        case 1
            plot(x,bsplMat(lpb,:),'k');
    end
end

for lpk = 1:length(b)
    strtLvl = 0;
    plot(b(lpk),strtLvl,'ks','MarkerSize',6);
    for lpm = 1:m(lpk)
        strtLvl = strtLvl - 0.05;
        plot(b(lpk),strtLvl,'ks','MarkerSize',6);
    end
end

xlabel('$x$','interpreter','latex','FontSize',14);
ylabel('$B_{i,k}(x;\overline{\tau})$','interpreter','latex','FontSize',14)
        