edit figure
set(gca,'ButtonDownFcn',@testBDF)
% plot([0 1 2],[0 1 2])

function testBDF(gcbo,EventData,handles)
    disp(gcbo.CurrentPoint)
end