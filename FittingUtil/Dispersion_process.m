classdef Dispersion_process < handle
    
    properties
        trans_raw  % [N * 1]
        MZI_raw    % [N * 1]
        D1_MZI_0
        D2_MZI_0
        D3_MZI_0
        scan_start
        scan_end
        center
        
        trans      % [N * 1]
        MZI        % [N * 1]
        timeline   % [N * 2]
        peaks_idx  % [M * 1]
        peaks_mag  % [M * 1]
        
        mode_hopping
        lastidx % lastest index of modes
        modefamily
    end
    
    properties (Dependent = true)
        peaks_frq  % [M * 1]
        disk_fsr
        curr_mode
    end
    
    properties (Access = private)
        % Something for old code
        Save = 0
        filename
    end
    
    methods
        function obj = Dispersion_process(trans_raw,MZI_raw,disk_FSR,scan_start,scan_end,center,D1,D2,D3,filename) % constructor
            if nargin >= 10
                obj.filename = filename;
                obj.Save = 1;
            end
            obj.trans_raw = trans_raw;
            obj.MZI_raw = MZI_raw;
            obj.scan_start = scan_start;
            obj.scan_end = scan_end;
            obj.center = center;
            obj.D1_MZI_0 = D1;
            obj.D2_MZI_0 = D2;
            obj.D3_MZI_0 = D3;
            obj.mode_hopping = [];
            obj.modefamily = {struct('D1',disk_FSR,'Offset',0)} ;
            obj.lastidx = 1;
        end
        
        function process(obj)
            obj.smooth;
            obj.createtimeline;
            obj.findmodes;
        end
        
        function add(obj,pos,mag)
            if ~isempty(obj.mode_hopping) && obj.mode_hopping(end,1) == pos
                obj.mode_hopping(end,2) = obj.mode_hopping(end,2)+mag;
            else
                obj.mode_hopping = [obj.mode_hopping;pos,mag];
            end
            close all;
            obj.plot_results;
        end
        
        function remove(obj)
            if size(obj.mode_hopping,1) > 1
                obj.mode_hopping = obj.mode_hopping(1:end-1,:);
            else
                obj.mode_hopping = [];
            end
            close all;
            obj.plot_results;
        end
        
        function fsr = get.disk_fsr(obj)
            fsr = obj.modefamily{1}.D1;
        end
        function set.disk_fsr(obj,fsr)
            obj.modefamily{1}.D1 = fsr;
        end
        
        function freq = get.peaks_frq(obj)
            freq = obj.timeline(obj.peaks_idx,1);
        end
        
        function mode = get.curr_mode(obj)
            mode = obj.modefamily{obj.lastidx};
        end
        
        function figure_handle = plotdata(obj,type)
            if nargin < 2
                type = '';
            end
            figure_handle = figure;
            hold on;
            xlabel('Pixel');
            ylabel('Transmission');
            if strcmp(type, 'raw')
                plot(obj.trans_raw);
                plot(obj.MZI_raw);
            else
                plot(obj.trans);
                plot(obj.MZI);
            end
            grid on;
            legend({'Transmission','MZI'});
            title('Dispersion Plot','FontSize',10,'FontWeight','normal');
            hold off;
        end
        
        function figure_handle = plot_results(obj,type,modenum)
            if nargin < 3
                if nargin < 2
                    type = 'raw';
                end
            else
                obj.lastidx = modenum;
            end
            mode = obj.curr_mode;
            obj.removehopping;
            figure_handle = figure;
            hold on;
            
            display_offset = -mode.D1/2;
            
            x = floor(obj.peaks_frq/mode.D1);
            y = obj.peaks_frq - x * mode.D1 + display_offset;
            xlabel('mode number (\mu)','fontsize',16);
            ylabel('(\omega-\omega_0-\muD_1)/2\pi (MHz)','fontsize',16);
            
            switch lower(type)
                case 'raw' % scatter
                    scatter(x,y,'linewidth',1);
%                     save(['FSR=',num2str(mode.D1),'.mat'],'x','y');
                    ylim([ display_offset, display_offset + mode.D1]);
                    if isfield(mode,'D2') && mode.D2 ~=0  % manual fit
                        x_axis=linspace(min(x),max(x),10000);
                        
                        if isfield(mode,'D4') && mode.D4 ~= 0
                            y_axis=0.5*mode.D2*(x_axis - mode.u0).^2 + mode.D3/6*(x_axis - mode.u0).^3 + mode.D4/24*(x_axis - mode.u0).^4;
                            mode_con = ['D_1=', num2str(mode.D1/10^3,7),'GHz ',...
                                'D_2=',num2str(mode.D2*1e3,4),'kHz ','D_3=',num2str(mode.D3*1e6,4),'Hz ',...
                                'D_4=',num2str(mode.D4*1e9,4),'mHz'];
                        else
                            y_axis=0.5*mode.D2*(x_axis - mode.u0).^2 + mode.D3/6*(x_axis - mode.u0).^3;
                            mode_con = ['D_1=', num2str(mode.D1/10^3,7),'GHz ',...
                                'D_2=',num2str(mode.D2*1e3,4),'kHz ','D_3=',num2str(mode.D3*1e6,4),'Hz',];
                        end
                        title(mode_con);
                        plot(x_axis,y_axis,'r','linewidth',2);
                        ylim([0.95*min(y_axis)-0.05*max(y_axis),0.95*max(y_axis)-0.05*min(y_axis)]);
                    end
                case 'color'
                    x_grid = linspace(min(x),max(x),max(x)-min(x)+1);
                    y_grid = linspace(min(y),max(y),500);
                    y_grid_range = max(y)-min(y);
                    trans_peak_map = ones(length(y_grid),length(x_grid));
                    for j1=1:length(obj.peaks_mag)
                        x_position = x(j1)-min(x_grid)+1;
                        y_position = floor((y(j1)-min(y))/y_grid_range*499)+1;
                        trans_peak_map(y_position,x_position) = obj.peaks_mag(j1);
                        trans_peak_map(max(y_position-1,1),x_position) = obj.peaks_mag(j1);
                        trans_peak_map(min(y_position+1,500),x_position) = obj.peaks_mag(j1);
                    end
                    pcolor(transpose(x_grid),transpose(y_grid),1 - trans_peak_map);
                    shading interp;
                    colorbar;
                    title('Transmission depth','Fontsize',16);
                    caxis([0 1])
                    xlim([min(x),max(x)]);
                    ylim([min(y),max(y)]);
                case {'fit','filter'}
                    % construct filter
                    if isfield(mode,'D4') && mode.D4 ~= 0
                        y_est = 0.5*mode.D2*(x - mode.u0).^2 + mode.D3/6*(x - mode.u0).^3 + mode.D4/24*(x - mode.u0).^4;
                    else
                        y_est = 0.5*mode.D2*(x - mode.u0).^2 + mode.D3/6*(x - mode.u0).^3;
                        mode.D4 = 0;
                    end
                    filter = find(abs(y_est - y) < 80);
                    x = x(filter);
                    y = y(filter);
                    T = obj.peaks_mag(filter);
                    wavelength = 299792458e3./(299792458e3/obj.center + obj.peaks_frq(filter));
                    save(['FSR=',num2str(mode.D1),'.mat'],'x','y','T','wavelength');
                    scatter(x,y,'linewidth',1);
                    if strcmp('fit',type)
                        ft = fittype('D4/24*x^4+D3/6*x^3+D2/2*x^2');
                        F0 = fit(x,y,ft,'StartPoint',[mode.D4 mode.D3 mode.D2]);
                        display(F0);
                        x_axis = linspace(min(x),max(x),10000);
                        y_axis = F0(x_axis);
                        plot(x_axis,y_axis,'r','linewidth',2);
                        ylim([0.95*min(y_axis)-0.05*max(y_axis),0.95*max(y_axis)-0.05*min(y_axis)]);
                    end
                case {'colorinv'}
                    x_grid = linspace(min(x),max(x),max(x)-min(x)+1);
                    y_grid = linspace(min(y),max(y),500);
                    y_grid_range = max(y)-min(y);
                    trans_peak_map = ones(length(y_grid),length(x_grid));
                    for j1=1:length(obj.peaks_mag)
                        x_position = x(j1)-min(x_grid)+1;
                        y_position = floor((y(j1)-min(y))/y_grid_range*499)+1;
                        trans_peak_map(y_position,x_position) = obj.peaks_mag(j1);
                        trans_peak_map(max(y_position-1,1),x_position) = obj.peaks_mag(j1);
                        trans_peak_map(min(y_position+1,500),x_position) = obj.peaks_mag(j1);
                    end
                    x_grid = 299792458./(mode.D1 * x_grid * 1e-3 + 299792458/obj.center);
                    pcolor(transpose(x_grid),transpose(y_grid),1 - trans_peak_map);
                    shading interp;
                    colorbar;
                    title('Transmission depth','Fontsize',16);
                    caxis([0 1])
                    xlim([min(x_grid),max(x_grid)]);
                    ylim([min(y),max(y)]);
                    xlabel('Wavelength (nm)','fontsize',16);
            end
            legend(sprintf('D1=%.3fGHz',mode.D1/1e3),'Location','Best');
            hold off
        end
        
        function figure_handle = plot_local(obj,u_min,u_max,modenum)
            if nargin < 4
                if nargin < 3
                    u_max = u_min;
                end
            else
                obj.lastidx = modenum;
            end
            mode = obj.curr_mode;
            obj.removehopping;
            figure_handle = figure;
            hold on;
            idx_min = obj.findidx( mode.D1 * u_min );
            idx_max = obj.findidx( mode.D1 * (u_max + 1) );
            idx_med = obj.findidx( mode.D1 * (u_min + u_max + 1)/2 );
            T = sign(idx_max - idx_min);
            x = (obj.timeline(idx_min:T:idx_max,1) -obj.timeline(idx_med,1) )/1e3;
            y = obj.trans_raw(idx_min:T:idx_max);
            y = y/max(y);
            plot(x,y);
            box on;
            set(gcf,'unit','centimeters','position',[2 2 20 12])
            xlabel('Detuning (GHz)');
            ylabel('Transmission');
%             ylim([0 1])
            hold off
        end
        
        function find_fsr(obj)
            f=@(k) sum(exp(1i*obj.peaks_frq*k));
            x=(1.5*pi/obj.disk_fsr):1e-8:(2.5*pi/obj.disk_fsr);
            [~,f_fsr]=findpeaks(abs(f(x)),x,'MinPeakHeight',30,'MinPeakProminence',10,'SortStr','descend');
            fsr_list=2*pi./f_fsr.';
            fprintf('Possible FSR[GHz]:\n');
            disp(fsr_list(1:min(10,end))/1e3);
        end
        
        function make_gif(obj, fsr_array, fileout)
            d_time=0.15; %delay time
            firstframe=1;
            modelist = obj.peaks_frq;
            hold off;
            for disk_FSR = fsr_array
                x = floor(modelist/disk_FSR);
                y = modelist - x * disk_FSR;
                grid on;
                scatter(x,y -disk_FSR/2 ,'linewidth',1);
                ylim([-max(fsr_array)/2, max(fsr_array)/2]);
                xlabel('mode number (u)','FontSize',16);
                ylabel('D_{int} (MHz)','FontSize',16);
                set(gcf,'Position', [100,329,1119,666]);
                legend(sprintf('D1=%.3fGHz',disk_FSR/1000),'Location','NorthEastOutside');
                
                drawnow
                frame = getframe(1);
                im = frame2im(frame);
                [imind,cm] = rgb2ind(im,256);
                if firstframe==1
                    imwrite(imind,cm, fileout,'gif', 'Loopcount',inf,'delaytime',d_time);
                    firstframe = 0;
                else
                    imwrite(imind,cm, fileout,'gif','WriteMode','append','delaytime',d_time);
                end
            end
        end
        
        function make_mov(obj, fsr_array, fileout)
            d_time=0.15; %delay time
            writerObj = VideoWriter(fileout);
            writerObj.FrameRate=1/d_time;
            open(writerObj)
            modelist = obj.peaks_frq;
            hold off;
            for disk_FSR = fsr_array
                x = floor(modelist/disk_FSR);
                y = modelist - x * disk_FSR;
                grid on;
                scatter(x,y -disk_FSR/2 ,'linewidth',1);
                ylim([-max(fsr_array)/2, max(fsr_array)/2]);
                xlabel('mode number (u)','FontSize',16);
                ylabel('D_{int} (MHz)','FontSize',16);
                set(gcf,'Position', [100,329,1119,666]);
                legend(sprintf('D1=%.3fGHz',disk_FSR/1000),'Location','NorthEastOutside');
                
                drawnow
                frame = getframe(1);
                writeVideo(writerObj,frame);
            end
            close(writerObj)
        end
    end
    
    methods (Access = private)
        function smooth(obj)
            disp('Smoothing all curves...');
            smoothscale = 1000;
            obj.trans=obj.trans_raw./smooth(obj.trans_raw,smoothscale);
            obj.MZI=obj.MZI_raw./smooth(obj.MZI_raw,smoothscale);
            obj.MZI=obj.MZI/median(obj.MZI)/2;
            if obj.Save == 1
                save([obj.filename, '_MZI.mat'],'MZI','-mat');
                save([obj.filename, '_transmission.mat'],'transmission','-mat');
            end
        end
        
        function createtimeline(obj)
            %build-in parameters
            sel_MZI = 5;
            thre_MZI_dip = 0.35;
            thre_MZI_peak = 0.65;
            
            disp('MZI processing...');
            
            sel = (max(obj.MZI)-min(obj.MZI))/sel_MZI;
            [dipMags,dipInds] = findpeaks(-obj.MZI,'MinPeakHeight',-thre_MZI_dip,'MinPeakProminence',sel);
            N_MZI_dip = length(dipInds);
            [peakMags,peakInds] = findpeaks(obj.MZI,'MinPeakHeight',thre_MZI_peak,'MinPeakProminence',sel);
            N_MZI_peak = length(peakInds);
            N_MZI_total_raw = N_MZI_dip + N_MZI_peak;
            
            MZI_peak_raw = [dipInds,dipMags,-ones(N_MZI_dip,1);peakInds,peakMags,ones(N_MZI_peak,1)];
            
            MZI_peak_raw = sortrows(MZI_peak_raw,1); %Sort the MZI peak by their index number
            
            MZI_peak_select = MZI_peak_raw;
            disp('Removing MZI hopping...')
            idx_select=1; %This is the pointer of the good peaks; while j is the pointer of all peaks.
            MZI_peak_select(1,:) = MZI_peak_raw(1,:); %take the first point, initial value;
            for idx_raw = 2:N_MZI_total_raw
                if MZI_peak_select(idx_select,3) + MZI_peak_raw(idx_raw,3) == 0   %if one is dip and another is peak, then it is correct;
                    idx_select = idx_select + 1;
                    MZI_peak_select(idx_select,:) = MZI_peak_raw(idx_raw,:);
                elseif MZI_peak_select(idx_select,2) - MZI_peak_raw(idx_raw,2) < 0 %if they are both peak, then select the larger one as peak;
                    MZI_peak_select(idx_select,:) = MZI_peak_raw(idx_raw,:);       %if they are both dip, then select the smaller one as peak;
                end
            end
            MZI_peak_select = MZI_peak_select(1:idx_select,:);
            
            N_MZI_peak=length(MZI_peak_select);
            
            disp('Creating timeline...')
            obj.timeline=zeros(length(obj.MZI),2);
            c = 299792458;
            f_scan_start = c/obj.scan_start*1e9;
            f_scan_end = c/obj.scan_end*1e9;
            f_center = c/obj.center*1e9;
            
            peak_center=(f_center-f_scan_start)/(f_scan_end-f_scan_start)*N_MZI_peak; % find the location of 775nm. This is the calibrated FSR position;
            peak_center=round(peak_center);
            
            Y_MZI=sign(obj.scan_start-obj.scan_end); %if Y_MZI=-1, means scan laser from short wavelength to long wavelength. means: MZI_FSR decrease with data number;
            for idx_raw=1:N_MZI_peak-1
                mu = Y_MZI*(idx_raw-peak_center)/2; %mode number of j peak; divided by 2 because it's counting both peak and dips of the MZI;
                d_N = MZI_peak_select(idx_raw+1,1) - MZI_peak_select(idx_raw,1);% number of points between two peaks;
                D1_MZI = obj.D1_MZI_0+obj.D2_MZI_0*mu + 1/2*obj.D3_MZI_0*mu^2; %FSR at peak mu or j;
                obj.timeline((MZI_peak_select(idx_raw,1)+1:MZI_peak_select(idx_raw+1,1))) = mu*obj.D1_MZI_0 + 1/2*obj.D2_MZI_0*mu^2 + 1/6*obj.D3_MZI_0*mu^3 + Y_MZI*D1_MZI/2*(1:d_N)/d_N;
            end
            obj.timeline(obj.timeline == 0) = NaN;
            obj.timeline(:,2) = obj.timeline(:,1); % Copyto raw timeline
            if obj.Save == 1
                save([file_name, '_MZI_peak_select.mat'],'MZI_peak_select');
                save([file_name, '_timeline.mat'],'timeline');
            end
        end
        
        function findmodes(obj)
            disp('Finding modes...')
            sel_trans = 12;
            thresh = 0.95;
            
            sel=max(obj.trans)/sel_trans;
            [obj.peaks_mag,obj.peaks_idx]=findpeaks(-obj.trans,'MinPeakHeight',-thresh,'MinPeakProminence',sel);
            obj.peaks_mag = -obj.peaks_mag;
            obj.peaks_mag(isnan(obj.peaks_frq)) = [];
            obj.peaks_idx(isnan(obj.peaks_frq)) = [];
            if obj.Save == 1
                trans_peak = [obj.peaks_idx,obj.peaks_mag];
                disp([num2str(size(trans_peak,1)) ' modes found']); % suppress warning
                save([file_name, '_trans_peak.mat'],'trans_peak');
            end
        end
        
        function removehopping(obj)
            mode = obj.modefamily{obj.lastidx};
            obj.timeline(:,1) = obj.timeline(:,2) + mode.Offset; % Copy raw timeline to real timeline
            for idx = 1:size(obj.mode_hopping,1)
                hopping_position = obj.findidx(obj.mode_hopping(idx,1) * mode.D1);
                obj.timeline(hopping_position:end,1) = obj.timeline(hopping_position:end,1) - obj.mode_hopping(idx,2)*obj.D1_MZI_0;
                % obj.timeline(hopping_position:end,1) = obj.timeline(hopping_position:end,1) - obj.mode_hopping(idx,2);
            end
        end
        
        function idx = findidx(obj, freq)
            [~,idx] = min(abs(obj.timeline(:,1) - freq));
        end
    end
end
