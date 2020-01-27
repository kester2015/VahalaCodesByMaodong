function UpdatePlot(log,handles,bUpdateFz,ax,varargin)
if nargin<3
    bUpdateFz=false;
end
if sum(strcmp(varargin,'.'))
    strLineStyle='.';
else
    strLineStyle='.-';
end
nindex=strcmp(varargin,'DoubleAxis');
if sum(nindex)
    bDoubleAxis=true;
    varargin(nindex)=[];
else
    bDoubleAxis=false;
end

if bUpdateFz
    if nargin<4
        ax=handles.axes2;
    end
    try
        cla(ax);
    catch
    end
    if bDoubleAxis
        fig=gcf;
        fig.WindowStyle='normal';
        fig.DockControls='off';
        fig.Units='centimeters';
        figPosition=[3 5 8.8 6.8157];
        fig.Position=figPosition;
        ax.Position=ax.Position.*[1, 1.4, 0.85 0.83];
    end
    log.VVFzMap.DrawSolitonBoundary(ax);
    hold(ax,'on');
    plot(ax,log.StateFz(:,1),log.StateFz(:,2),['b' strLineStyle],'LineWidth',1,'MarkerSize',12);
    xlabel(ax,'Normalized detuning');
    ylabel(ax,'Normalized Power');
    if ~isempty(log.FzLowerBoundry)
        plot(log.FzLowerBoundry(:,1),log.FzLowerBoundry(:,2),'kx');
    end
    if ~isempty(log.FzUpperBoundry)
        plot(log.FzUpperBoundry(:,1),log.FzUpperBoundry(:,2),'bx');
    end    
    
    % draw history: in Fzhistory but not in StateFz
%     [Fzhistory,~]=DeleteVectorFromMatrix(log.StateFz,true);
    try
        plot(ax,log.Fzhistory(:,1),log.Fzhistory(:,2),strLineStyle,'Color',[208,208,208]/256,'MarkerSize',12)
    catch
    end
    
    hold(ax,'off');
    YLim=[4,max(log.StateFz(:,2))];
    XLim=[3.5,max(log.StateFz(:,1))];
    kappa=3e14/1.55/log.Qloaded; % no 2pi
    ylim(ax,YLim);
    xlim(ax,XLim);
    ax.XColor='k';
    ax.YColor='k';
    
    if bDoubleAxis
        box(ax,'off');
        ax2 = axes('Position',ax.Position,'XAxisLocation','top','YAxisLocation','right',...
            'Color','none','XColor','b','YColor','b');
        ylim(ax2,YLim*log.VVFzMap.Pth*1e3);
        ylabel(ax2,'Pump power (mW)','Rotation',270,'HorizontalAlignment','center' ,'VerticalAlignment','bottom','Color','b');
        xlim(ax2,XLim*kappa/2e6);
        xlabel(ax2,'Cavity-pump detuning (MHz)','VerticalAlignment','baseline','Color','b');
        
        fig.InnerPosition=fig.InnerPosition.*[1,1,1,1.1];
    end
else
    if nargin<4
        ax=handles.axes1;
    end
    cla(ax);
    plot(ax,log.StateVV(:,1),log.StateVV(:,2),strLineStyle,'LineWidth',1,'MarkerSize',12);
    xlabel(ax,'Servo DC offset Voltage (V)');
    ylabel(ax,'AOM Voltage (V)');
    hold(ax,'on');
    if ~isempty(log.VaomLowerBoundry)
        plot(log.VaomLowerBoundry(:,1),log.VaomLowerBoundry(:,2),'kx');
    end
    if ~isempty(log.VaomUpperBoundry)
        plot(log.VaomUpperBoundry(:,1),log.VaomUpperBoundry(:,2),'bx');
    end        
        
    % draw history
    if ~isempty(log.VVhistory)
        plot(ax,log.VVhistory(:,1),log.VVhistory(:,2),'.','Color',[208,208,208]/256,'MarkerSize',12)
    end
    hold(ax,'off');
    
end
end